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

  serialize :template

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

  def translate_body(pdf, text)
    # We're going to be parsing each line as we go.
    text.gsub(/\r/,'').split(/\n/).each do |line|
      parse_line(pdf, line)
    end
  end

  def parse_line(pdf, line)
    size = 13
    align = :center
    at = nil
    line.gsub!(/%PAD(-\d+|\d+)%/) {pdf.pad_top($1);''}
    line.gsub!(/%PROP_POST_PAD(-\d+|\d+)%/) {unless self.prop_season.property_post_text.blank? then pdf.pad_top($1) end;self.prop_season.property_post_text}
    line.gsub!(/%PROP_PRE_PAD(-\d+|\d+)%/) {unless self.prop_season.property_pre_text.blank? then pdf.pad_top($1) end;self.prop_season.property_pre_text}
    line.gsub!(/%PROP_GREETING_PAD(-\d+|\d+)%/) {unless self.greeting.blank? then pdf.pad_top($1) end; self.greeting }
    line.gsub!(/%SEASON_PRE_PAD(-\d+|\d+)%/) {unless self.season.pre_text.blank? then pdf.pad_top($1) end;self.season.pre_text}
    line.gsub!(/%SEASON_POST_PAD(-\d+|\d+)%/) {unless self.season.post_text.blank? then pdf.pad_top($1) end;self.season.post_text}
    line.gsub!(/%CLIENT_SALUTATION_PAD(-\d+|\d+)%/) {unless self.client.full_salutation.blank? then pdf.pad_top($1) end; self.client.full_salutation}

    line.gsub!(/%PROP_POST%/, self.prop_season.property_post_text)
    line.gsub!(/%PROP_PRE%/, self.prop_season.property_pre_text)
    line.gsub!(/%PROP_GREETING%/, self.greeting)
    line.gsub!(/%SEASON_PRE%/, self.season.pre_text)
    line.gsub!(/%SEASON_POST%/, self.season.post_text)
    line.gsub!(/%CLIENT_SALUTATION%/, self.client.full_salutation)
    
    line.gsub!(/%ALIGN_(CENTER|LEFT|RIGHT)%/) {align=$1.downcase.to_sym;''}
    line.gsub!(/%SIZE_(\d+)%/) {size=$1.to_i;''}
    line.gsub!(/%AT_(\d+)_(\d+)%/) {at = [$1,$2];''}
    line.gsub!(/%IMAGE\[([^|]+)|(\d+)|(\d+)\]%/) {if at then pdf.image $1, :at => at, :width => $2, :height => $3 else pdf.image $1, :width => $2, :height => $3  end;''}

    unless line.blank?
      if at
        pdf.text line, :at => at, :align => align, :size => size
      else
        pdf.text line, :align => align, :size => size
      end
    end
  end

  def fonts
    self.template[:fonts]
  end

  def fonts=(vals)
    unless vals.is_a? Array
      vals = [vals]
    end
    self.template[:fonts] = vals
  end

  def styles
    self.template[:styles]
  end

  def styles=(vals)
    if vals.is_a? Hash
      self.template[:styles] = vals
    end
  end

  def body
    self.template[:body]
  end

  def body=(val)
    self.template[:body] = val.to_s
  end
end
