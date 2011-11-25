class CifsController < ApplicationController
  before_filter :authenticate_user!, :except => [:home, :access, :fill]
  before_filter :is_administrator?, :except => [:home, :access, :fill, :index, :show, :edit, :update, :create]

  STATUSES = %w(unsent flagged sent captured completed all)
  SORT_MAPPING = {:client => "clients.last_name", :company => "companies.name", :property => "properties.code", :created_by => "users.last_name, users.first_name", :name => "clients.last_name, clients.first_name"}

  def home
  end

  def index
    setup_session_defaults_for_controller(:cifs, :client)

    session[:cifs] ||= {}
    session[:cifs][:status] ||= 'unsent'
    session[:cifs][:start_date] ||= 2.months.ago
    session[:cifs][:end_date] ||= Time.now
    session[:cifs][:collapse] ||= false

    if params[:status] and STATUSES.include? params[:status]
      session[:cifs][:status] = params[:status]
    end

    if params[:start_date]
      session[:cifs][:start_date] = params[:start_date]
    end

    if params[:end_date]
      session[:cifs][:end_date] = params[:end_date]
    end

    if params[:collapse]
      session[:cifs][:collapse] = params[:collapse]
    end

    if @property = Property.find_by_id(session[:cifs][:property_id])
      unless current_user.admin? or current_user.all_properties.include? @property
        session[:cifs][:property_id] = 0
        @property = nil
      end
    end

    if @property
      @properties = [@property]
    else
      unless current_user
        @properties = current_user.all_properties
      else
        @properties = Property.all
      end
    end

    @season = Season.find_or_create_by_name('Thank You')

    @cifs = Cif.joins([:client => :company], :property).where(['end_date between ? and ? and cifs.property_id in (?)', session[:cifs][:start_date], session[:cifs][:end_date], @properties.collect{|r| r.id}])

    @cifs = @cifs.order(SORT_MAPPING[session[:sorters][:cifs][:field]] || "cifs.#{session[:sorters][:cifs][:field]}")
    if session[:sorters][:cifs][:order] == 'DESC'
      @cifs = @cifs.reverse
    end

    case session[:cifs][:status]
      when 'unsent'
        @cifs = @cifs.where(["sent_at is null and (flagged_until is null or flagged_until < ? or (cifs.updated_at > (cifs.flagged_until - INTERVAL '7 days') or clients.updated_at > (cifs.flagged_until - INTERVAL '7 days') or companies.updated_at > (cifs.flagged_until - INTERVAL '7 days')))", Time.now])
      when 'flagged'
        @cifs = @cifs.where(["sent_at is null and not (flagged_until is null or flagged_until < ? or (cifs.updated_at > (cifs.flagged_until - INTERVAL '7 days') or clients.updated_at > (cifs.flagged_until - INTERVAL '7 days') or companies.updated_at > (cifs.flagged_until - INTERVAL '7 days')))", Time.now])
      when 'sent'
        @cifs = @cifs.where(["sent_at is not null"]).where({:cif_captured => false})
      when 'captured'
        @cifs = @cifs.where({:cif_captured => true})
      when 'completed'
        @cifs = @cifs.where(['completed_at is not null'])
    end

    if session[:cifs][:page_id] > 1 and @cifs.count > (session[:cifs][:page_id] - 1) * ApplicationController::RECORDS_PER_PAGE
      session[:cifs][:page_id] = 1
    end

    @cifs = @cifs.page(session[:cifs][:page_id])
  end

  def send_survey
    unless @cif = Cif.find_by_id(params[:id])
      unless @cif.client.email
        @message = 'Client has no email address configured, cannot send survey.'
      else
        if @cif.sent_at
          @message = "Survey was already sent at #{@cif.sent_at.to_s(:date_time12)}"
        else
          begin
            SurveyMailer.survey_email(@cif).deliver
          rescue Net::SMTPFatalError => e
            @message = "A permanent error occured while sending the survey to '#{@cif.client}'. Please check the e-mail address.<br/>Error is: #{e}<br />"
          rescue Net::SMTPServerBusy, Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError => e
            @message = "An error occured while sending the survey to '#{@cif.client}'. Please check the e-mail address.<br/>Error is: #{e}<br />"
          else
            @cif.update_attributes(:sent_at => Time.now, :approved_by => current_user.id, :flagged_until => Time.now, :client_contact_info => @cif.client.email, :without_protection => true)
            @message = 'Survey sent.'
          end
        end
      end
    end

    unless request.xhr?
      flash[:notice] = @message
      redirect_to cifs_path
    end
  end

  def capture
    unless @cif = Cif.find_by_id(params[:id])
      @cif.update_attributes(:sent_at => Time.now, :cif_captured => true, :without_protection => true)
      if @cif.flagged_until and @cif.flagged_until > Time.now
        @cif.update_attribute(:flagged_until, Time.now)
      end
      @message = 'Survey captured'
    else
      @message = 'No survey with that ID exists.'
    end

    unless request.xhr?
      flash[:notice] = @message
      redirect_to cifs_path
    end
  end

  def include
    if @cif = Cif.find_by_id(params[:id])
      if @cif.count_survey
        flash[:error] = 'That survey is already being counted.'
      else
        @cif.update_attribute(:count_survey, true)
        flash[:notice] = 'Survey will now be counted in results.'
      end
    else
      flash[:error] = 'I could not find a survey with that ID.'
    end
    redirect_to cifs_path
  end

  def declude
    if @cif = Cif.find_by_id(params[:id])
      unless @cif.count_survey
        flash[:error] = 'That survey is already not being counted.'
      else
        @cif.update_attribute(:count_survey, true)
        flash[:notice] = 'Survey will no longer be counted in results.'
      end
    else
      flash[:error] = 'I could not find a survey with that ID.'
    end
    redirect_to cifs_path
  end

  def access
    unless @cif = Cif.find_by_id_and_passcode(params[:id], params[:passcode])
      flash[:error] = 'I could not find a survey with that information.  Please email your VAE contact for another survey.'
      redirect_to root_path
    else
      if @cif.completed_at
        flash[:error] = 'This survey has already been submitted.'
        redirect_to root_path
      else
        unless @cif.clicked_at
          @cif.update_attribute(:clicked_at, Time.now)
        end
        render :layout => 'public'
      end
    end
  end

  def fill
    unless @cif = Cif.find_by_id_and_passcode(params[:id], params[:passcode])
      flash[:error] = 'I could not find a survey with that information.  Please email your VAE contact for another survey.'
      redirect_to root_path
    else
      if @cif.completed_at
        flash[:error] = 'This survey has already been submitted.'
        redirect_to root_path
      else
        case @cif.cif_form
          when 'vae_conventions'
            params[:cif][:overall_satisfaction] = params[:cif][:answers][14]
          when 'csi'
            params[:cif][:overall_satisfaction] = params[:cif][:answers][12]
          else
            params[:cif][:overall_satisfaction] = params[:cif][:answers][7]
        end

        if params[:cif][:client_comments]
          params[:cif][:client_comments].gsub!(/\r/,'')
        end
        params[:cif][:next_meeting] = Chronic.parse(params[:cif][:next_meeting])

        @cif.update_attributes(params[:cif], :as => :public)

        @cif.send_emails_if_necessary
      end
    end
  end

  def show
    unless @cif = Cif.find_by_id(params[:id])
      flash[:error] = 'I could not find a survey with that ID.'
      redirect_to cifs_path
    else
      @season = Season.find_or_create_by_name('Thank You')
    end
  end

  def review
    unless @cif = Cif.find_by_id(params[:id])
      flash[:error] = 'I could not find a survey with that ID.'
      redirect_to cifs_path
    end
  end

  def resend
    unless @cif = Cif.find_by_id(params[:id])
      flash[:error] = 'I could not find a survey with that ID.'
      redirect_to cifs_path
    else
      @new_cif = @cif.clone
      @new_cif.save

      if @cif.sent_at
        @cif.update_attributes(:count_survey => false)
      else
        @cif.update_attributes(:count_survey => false, :sent_at => Time.now)
      end

      if @cif.flagged_until and @cif.flagged_until > Time.now
        @cif.update_attribute(:flagged_until, Time.now)
      end

      params[:id] = @new_cif.id
      send
    end
  end

  def new
    unless @client = Client.find_by_id(params[:client_id])
      flash[:notice] = 'You must supply a client to create a new survey.'
      redirect_to clients_path
    else
      unless current_user.admin? or current_user.all_properties.include? @client.property
        flash[:notice] = 'You cannot create a new survey for that client.'
        redirect_to clients_path
      else
        @cif = Cif.new(:client_id => @client.id)
      end
    end
  end

  def create
    unless @property = Property.find_by_id(params[:cif][:property_id])
      flash[:error] = "I could not find that property."
      redirect_to clients_path
    else
      unless current_user.admin? or current_user.all_properties.include? @property
        flash[:error] = 'You care not cleared to create cifs for that property.'
        redirect_to clients_path
      else
        if @cif = Cif.create(params[:cif].merge({:creator_id => current_user.id}), :without_protection => true)
          flash[:notice] = 'Survey created.'
          redirect_to cifs_path
        else
          flash[:error] = "There was an error creating the survey."
          redirect_to new_cif_path(:client_id => params[:cif][:client_id])
        end
      end
    end
  end

  def edit
    unless @cif = Cif.find_by_id(params[:id])
      flash[:error] = 'I could not find a survey with that ID.'
      redirect_to cifs_path
    end
  end

  def update
    unless @cif = Cif.find_by_id(params[:id])
      flash[:error] = 'I could not find a Survey with that ID.'
    else
      if @cif.completed_at
        flash[:error] = 'This survey has already been submitted.'
      else
        if params[:cif][:employee_comments]
          params[:cif][:employee_comments].gsub!(/\r/,'')
        end

        if @cif.update_attributes(params[:cif], :as => :internal)
          flash[:notice] = 'Survey was successfully updated.'
        else
          redirect_to edit_cif_path(@cif)
          return
        end
      end
    end
    redirect_to cifs_path
  end

  def flag
    unless @cif = Cif.find_by_id(params[:id])
      if @cif.sent_at
        flash[:error] = 'That survey has already been sent.'
      else
        @cif.flagger = current_user
        @cif.flagged_until = 7.days.from_now
        @cif.flag_comment = params[:comment]
        @cif.save

        TrackLogger.log("#{current_user} just flagged a survey (ID: #{@cif.id}) for client #{@cif.client} - #{@cif.company} at #{Time.now.to_s(:date_time12)}.")

        flash = @cif.notify_users_about_flag
      end
    else
      flash[:error] = 'I could not find a survey by that ID.'
    end
    redirect_to cifs_path
  end

  def destroy
    unless @cif = Cif.find_by_id(params[:id])
      flash[:error] = 'I could not find a survey by that ID.'
    else
      if @cif.sent_at
        flash[:error] = 'Survey cannot be deleted as it has already been sent.'
      else
        @cif.destroy
        flash[:notice] = 'Survey deleted.'
      end
    end
    redirect_to cifs_path
  end
end