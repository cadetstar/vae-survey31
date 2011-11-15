class PropSeason < ActiveRecord::Base
  belongs_to :season
  belongs_to :property

  has_many   :thank_you_cards

  before_destroy :prevent_if_thank_you_cards

  validates_length_of :property_pre_text, :max => (self.season.try(:property_char_limit) || 200), :too_long => "Pre Text cannot be longer than #{self.season} characters"
  validates_length_of :property_post_text, :max => (self.season.try(:property_char_limit) || 200), :too_long => "Post Text cannot be longer than #{self.season} characters"
  validates_length_of :property_signoff, :max => (self.season.try(:property_char_limit) || 200), :too_long => "Signoff cannot be longer than #{self.season} characters"

  def prevent_if_thank_you_cards
    self.thank_you_cards.size == 0
  end

  def to_s
    ps_std
  end

  def ps_std
    "#{self.property} for #{self.season}"
  end

end
