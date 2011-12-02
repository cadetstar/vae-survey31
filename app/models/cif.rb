class Cif < ActiveRecord::Base
  belongs_to :client
  belongs_to :property
  belongs_to :thank_you_card

  belongs_to :creator, :class_name => "User"
  belongs_to :approver, :class_name => "User"
  belongs_to :flagger, :class_name => "User"

  delegate :company, :to => :client
  delegate :cif_form, :to => :property

  serialize :answers

  validates_presence_of :start_date, :end_date, :client_id

  before_create :set_defaults
  before_save :calculate_average_score

  attr_accessible :answers, :client_comments, :number_of_meetings, :next_meeting, :please_contact, :submittor, :contact_info, :had_si, :had_ar, :had_ptt,
                  :employee_comments, :overall_satisfaction, :as => :public

  attr_accessible :location, :notes, :start_date, :end_date, :count_survey,
                  :as => :internal

  attr_accessible


  FORMS = %w(vae vae_conventions vae_french csi)

  def send_emails_if_necessary
    # TODO: Write this!
  end

  def caring_users
    ([self.property.manager] + self.property.users).uniq
  end

  def notify_users_about_flag
    # TODO: Write this!
    responses = {}
    responses[:notice] = []
    responses[:error] = []
    self.caring_users.each do |user|
      if user.receive_flags?
        begin
          SurveyMailer.flagged_survey(self, user).deliver
        rescue Net::SMTPFatalError => e
          responses[:error] << "A permanent error occured while sending the flag message to '#{user.name_std}'. Please check the e-mail address.<br/>Error is: #{e}<br />"
          TrackLogger.log "An attempt was made to email #{user.name_std} for CIF #{self.id}, but failed due to an SMTP fatal error."
        rescue Net::SMTPServerBusy, Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError => e
          responses[:error] << "An error occured while sending the flag message to '#{user.name_std}'. Please check the e-mail address.<br/>Error is: #{e}<br />"
          TrackLogger.log "An attempt was made to email #{user.name_std} for CIF #{self.id}, but failed due to an SMTP general error."
        else
          TrackLogger.log "An email has been sent to #{user} for CIF #{self.id}."
        end
      end
    end
    responses
  end

  def set_defaults
    self.passcode = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join)[0..10]
    self.submittor ||= "Unknown"

    if !self.location.blank?
      if self.location.upcase == self.location or self.location.downcase == self.location
        self.location = self.location.titleize
      end
      self.location = "The #{self.location}" unless self.location[0..2].downcase == 'the'
    end

    self.sent_at = nil
    self.clicked_at = nil
    self.completed_at = nil
    self.answers = {}
    self.overall_satisfaction = 0
    self.count_survey = true
  end

  def flagged?
    self.flagged_until and self.flagged_until > Time.now
  end

  def has_been_updated
    if self.flagged?
      self.flagged_until - 7.days + 1.minute < self.latest_updated_at
    else
      false
    end
  end

  def latest_updated_at
    [self.updated_at, self.client.try(:updated_at), self.company.try(:updated_at)].max
  end

  def sendable?
    !self.property.do_not_send_surveys_for_property and !self.notes.to_s.downcase.include?('dns')
  end

  def calculate_average_score
    self.answers ||= {}
    valid_answers = self.answers.select{|k,v| v.to_i > 0}.values.collect{|v| v.to_i}

    self.average_score = (valid_answers.size > 0 ? valid_answers.sum.to_f / valid_answers.size : 0)
  end

  def status
    unless self.sent_at
      'Survey has not yet been sent'
    else
      unless self.completed_at
        if self.cif_captured
          'Survey has been captured'
        else
          'Survey has not yet been completed'
        end
      else
        "Survey completed on #{self.completed_at.to_s(:date_time12)} with a score of #{sprintf('%.2f', self.average_score)}"
      end
    end
  end

  def get_tooltip(user)
    if user.admin?
      if self.flagged?
        if self.flag_comment.blank?
          'No Flag Comment'
        else
          self.flag_comment.truncate(20)
        end
      end
    end
  end

  def formatted_end_date
    self.end_date.to_s(:shortdate)
  end

  def formatted_completed_date
    self.completed_at.to_s(:shortdate)
  end

  def formatted_average_score
    sprintf('%.2f', self.average_score)
  end

  def date_format
    self.cif_form == 'vae_french' ? :french : :shortdate
  end

  def description_of_dates
    self.end_date >= (self.start_date + 1.day) ? "from #{self.start_date.to_s(self.date_format)} to #{self.end_date.to_s(self.date_format)}" : "on #{self.start_date.to_s(self.date_format)}"
  end

  def self.serialized_accessor(*args)
    args.each do |method_name|
      eval "
        def cif_answers_#{method_name}
          (self.answers || {})[#{method_name}]
        end

        def cif_answers_#{method_name}=(val)
          self.answers ||= {}
          self.answers[#{method_name}] = val
        end
        attr_accessible :cif_answers_#{method_name}, :as => :public

      "
    end
  end

  serialized_accessor *(1..16).to_a
end
