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
    return unless self.prop_season
    pdf = Prawn::Document.new
    self.season.fonts.each do |font|
      pdf.font font
    end

    translate_body(pdf, self.season.body)

    filename = "files/pdfs/#{self.id}.pdf"
    pdf.render_file filename

    jpeg_file = ImageList.new(filename) {self.density = "400x400"}
    jpeg_file.resize_to_fit!(800)
    jpeg_file.write("files/images/#{self.id}.jpg") {self.quality = 81}
  end

  def translate_body(pdf, text)
    # We're going to be parsing each line as we go.
    text.gsub!(/\r/,'')
    text.gsub(/~START_BLOCK\((\d+),(\d+),(\d+),(\d+)\)~([^~]+)~END_BLOCK~/m) { pdf.bounding_box([$1.to_i, $2.to_i], :width => $3.to_i, :height => $4.to_i) do translate_body(pdf, $5) end;''}
    text.gsub(/\r/,'').split(/\n/).each do |line|
      parse_line(pdf, line)
    end
  end

  def parse_line(pdf, line)
    size = 13
    align = :center
    at = nil
    inline = false

    line.gsub!(/%PAD(-\d+|\d+)%/) {pdf.pad_top($1);''}
    line.gsub!(/%PROP_POST_PAD(-\d+|\d+)%/) {unless self.prop_season.property_post_text.blank? then pdf.pad_top($1) end;self.prop_season.property_post_text}
    line.gsub!(/%PROP_PRE_PAD(-\d+|\d+)%/) {unless self.prop_season.property_pre_text.blank? then pdf.pad_top($1) end;self.prop_season.property_pre_text}
    line.gsub!(/%PROP_SIGNOFF_PAD(-\d+|\d+)%/) {unless self.prop_season.property_signoff.blank? then pdf.pad_top($1) end; self.prop_season.property_signoff}
    line.gsub!(/%PROP_GREETING_PAD(-\d+|\d+)%/) {unless self.greeting.blank? then pdf.pad_top($1) end; self.greeting }
    line.gsub!(/%SEASON_PRE_PAD(-\d+|\d+)%/) {unless self.season.pre_text.blank? then pdf.pad_top($1) end;self.season.pre_text}
    line.gsub!(/%SEASON_POST_PAD(-\d+|\d+)%/) {unless self.season.post_text.blank? then pdf.pad_top($1) end;self.season.post_text}
    line.gsub!(/%CLIENT_SALUTATION_PAD(-\d+|\d+)%/) {unless self.client.full_salutation.blank? then pdf.pad_top($1) end; self.client.full_salutation}

    line.gsub!(/%PROP_POST%/, self.prop_season.property_post_text)
    line.gsub!(/%PROP_PRE%/, self.prop_season.property_pre_text)
    line.gsub!(/%PROP_SIGNOFF%/, self.prop_season.property_signoff)
    line.gsub!(/%PROP_GREETING%/, self.greeting)
    line.gsub!(/%SEASON_PRE%/, self.season.pre_text)
    line.gsub!(/%SEASON_POST%/, self.season.post_text)
    line.gsub!(/%CLIENT_SALUTATION%/, self.client.full_salutation)
    
    line.gsub!(/%ALIGN_(CENTER|LEFT|RIGHT)%/) {align=$1.downcase.to_sym;''}
    line.gsub!(/%SIZE_(\d+)%/) {size=$1.to_i;''}
    line.gsub!(/%AT_(\d+)_(\d+)%/) {at = [$1,$2];''}
    line.gsub!(/%IMAGE\[([^|]+)|(\d+)|(\d+)\]%/) {settings = {:width => $2.to_i, :height => $3.to_i, :align => :center};if at then settings.merge!(:at => at) end; pdf.image $1, *settings;''}
    line.gsub!(/%INLINE%/) {inline = true;''}

    line.gsub!(/^([^%]+)%CAPIT_(\d+)%/) {inline = true;"<font size='#{$2}'>#{$1[0..0]}</font>#{$1[1..-1]}"}
    line.gsub!(/^([^%]+)%TITLEIT_(\d+)%/) {inline = true;$1.split(' ').collect{|k| "<font size='#{$2}'>#{k[0..0]}</font>#{k[1..-1]}"}.join(" ")}

    unless line.blank?
      vals = [:align => align, :size => size]

      if at
        vals << {:at => at}
      end
      if inline
        vals << {:inline_format => true}
      end
      pdf.text line, *vals
    end
  end

end
