class TrackLogger < ActiveSupport::BufferedLogger
  def initialize
    self.auto_flushing = true
  end

  def self.get_log
    @@log ||= TrackLogger.new(File.join(Rails.root, 'log', "tracking_#{Time.now.to_s(:file_date)}.log"))
  end

  def self.log(message, severity = DEBUG)
    self.get_log.add(severity, message)
  end
end