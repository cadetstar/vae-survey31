class Company < ActiveRecord::Base
  has_many :clients
  has_many :thank_you_cards, :through => :clients
  has_many :cifs, :through => :clients

  belongs_to :property

  def self.search_field
    "name"
  end

  def to_s
    company_std
  end

  def company_std
    "#{name} - #{city}, #{state}"
  end

  def full_address
    [self.address_line_1, self.address_line_2, "#{self.city}, #{self.state} #{self.zip}"].compact.join("<br />")
  end
end
