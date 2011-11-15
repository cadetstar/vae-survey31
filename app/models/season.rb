class Season < ActiveRecord::Base
  has_many :prop_seasons
  has_many :properties, :through => :prop_seasons
  has_many :thank_you_cards, :through => :prop_seasons

  validates_presence_of :name

  before_destroy :can_destroy
  before_create :set_templates

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
end
