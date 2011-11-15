class ThankYouCard < ActiveRecord::Base
  require 'RMagick'
  include Magick

  belongs_to :client
  belongs_to :prop_season

  delegate :property, :season, :to => :prop_season
  delegate :company, :to => :client

  before_save :generate_passcode
  after_save  :update_pdf_and_jpeg

  attr_accessible :client_id, :prop_season_id, :greeting, :sent_at

  def status
    unless self.sent_at
      'Email Not Sent Yet'
    else
      "Email Sent at: #{self.sent_at.to_s(:date_time12)}"
    end
  end

  def generate_passcode
    self.passcode = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join)[0..10]
  end

  def update_pdf_and_jpeg

  end
end
