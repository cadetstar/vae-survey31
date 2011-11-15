class CifsController < ApplicationController

  def home
  end

  def index

  end

  def send

  end

  def capture

  end

  def include

  end

  def declude

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

  def show

  end

  def review

  end

  def resend

  end

  def new

  end

  def edit

  end

  def update
    if params[:cif][:employee_comments]
      params[:cif][:employee_comments].gsub!(/\r/,'')
    end

  end

  def flag

  end

  def destroy
    unless @cif = Cif.find_by_id(params[:id])
      flash[:error] = 'I could not find a survey by that name.'
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