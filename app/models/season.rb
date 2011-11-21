class Season < ActiveRecord::Base
  has_many :prop_seasons
  has_many :properties, :through => :prop_seasons
  has_many :thank_you_cards, :through => :prop_seasons

  validates_presence_of :name

  before_destroy :can_destroy
  before_create :set_templates

  serialize :template

  TEMPLATE_MAIN = <<-MAIN
<html>
<head>
  <meta http-equiv=Content-Type content="text/html; charset=us-ascii">
  <title>Happy Holidays from Visual Aids Electronics!</title>
</head>
<body>
<table style="width: 100%; border-collapse: collapse; border:none; padding: 0; margin: 0;">
  <tr style="padding: 0px; margin: 0px;">
    <td style="text-align: center; background-color: #FFFFFF;">
      <img src="cid:%CID%" />
    </td>
  </tr>
</table>
</body>
  MAIN

  TEMPLATE_PLAIN = <<-PLAIN
To view this greeting card in HTML, please visit %GREETING_URL%

Dear %FULL_SALUTATION%,

%PLAIN_TEXT_INSERT%

Sincerely,

Visual Aids Electronics

%PROPERTY_SIGNOFF%
  PLAIN

  def unsent_emails
    unsent
  end

  def unsent
    self.thank_you_cards.select{|t| t.sent_at.nil?}.size
  end

  def property_ids
    self.properties.collect{|r| r.id}
  end

  def property_ids=(new_ids)
    self.prop_seasons.where(['property_id not in (?)', new_ids]).all.each do |ps|
      ps.destroy
    end

    (new_ids - self.property_ids).each do |p_id|
      self.prop_seasons.create(:property_id => p_id)
    end
  end

  def can_destroy
    self.thank_you_cards.size == 0
  end

  def to_s
    name
  end

  def set_templates
    self.email_template = TEMPLATE_MAIN
    self.email_template_plain = TEMPLATE_PLAIN
  end

  def fonts
    self.template ||= {}
    self.template[:fonts] || []
  end

  def fonts=(vals)
    unless vals.is_a? Array
      vals = [vals]
    end
    self.template ||= {}
    self.template[:fonts] = vals
  end

  def styles
    self.template ||= {}
    self.template[:styles] || {}
  end

  def styles=(vals)
    if vals.is_a? Hash
      self.template ||= {}
      self.template[:styles] = vals
    end
  end

  def style_text
    styles.collect do |k,v|
      "#{k.to_s}|#{v.collect{|a,b| "#{a}~#{b}"}.join("|")}"
    end.join(/\r\n/)
  end

  def style_text=(text)
    data = {}
    text.gsub!(/\r/)
    text.split(/\n/).each do |line|
      if line.match(/|/)
        vals = line.split(/|/)
        vals.reject!{|v| v.blank?}
        data[vals[0].to_sym] = {}
        vals[1..-1].each do |entry|
          if entry.match(/~/)
            kv = entry.split(/~/)
            if kv.size == 2
              data[vals[0].to_sym][kv[0].to_sym] = (kv[1].to_i.to_s == kv[1] ? kv[1].to_i : kv[1])
            end
          end
        end
      end
    end
    styles = data
  end

  def body
    self.template ||= {}
    self.template[:body] || ''
  end

  def body=(val)
    self.template ||= {}
    self.template[:body] = val.to_s
  end
end
