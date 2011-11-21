class PropSeason < ActiveRecord::Base
  belongs_to :season
  belongs_to :property

  has_many   :thank_you_cards

  before_destroy :prevent_if_thank_you_cards

  def prevent_if_thank_you_cards
    self.thank_you_cards.size == 0
  end

  def to_s
    ps_std
  end

  def ps_std
    "#{self.property} for #{self.season}"
  end

  validate do |ps|
    if self.season
      [:property_pre_text, :property_post_text, :property_signoff].each do |field|
        if self.send(field).to_s.length > self.season.property_char_limit
          ps.errors.add "#{field.titleize} cannot be longer than #{self.season.property_char_limit} characters."
        end
      end
    end
  end

end
