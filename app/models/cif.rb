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

  attr_accessible :answers, :client_comments, :number_of_meetings, :next_meeting, :please_contact, :submittor, :contact_info,
                  :overall_satisfaction, :as => :public

  attr_accessible :location, :notes, :employee_comments, :start_date, :end_date, :count_survey, :had_si, :has_ar, :had_ptt,
                  :as => :internal


  FORMS = %w(vae vae_conventions vae_french csi)

  def send_emails_if_necessary
    # TODO: Write this!
  end

  def set_defaults
    self.passcode = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join)[0..10]
    self.client_submittor = (self.client || "Unknown")

    if !self.location.blank?
      if self.location.upcase == self.location or self.location.downcase == self.location
        self.location = self.location.split.collect{|c| c.capitalize}.join(" ")
      end
      self.location = "The #{self.location}" unless self.location[0..2].downcase == 'the'
    end

    self.sent_at = nil
    self.clicked_at = nil
    self.completed_at = nil
    self.answers = {}
    self.overall_satisfaction = 0
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

  def average_score
    valid_answers = self.answers.select{|k,v| v.to_i > 0}.values

    valid_answers.size > 0 ? valid_answers.sum.to_f / valid_answers.size : 0
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
end
