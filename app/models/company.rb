class Company < ActiveRecord::Base
  has_many :clients
  has_many :thank_you_cards, :through => :clients
  has_many :cifs, :through => :clients

  belongs_to :property

  def to_s
    company_std
  end

  def company_std
    "#{name} - #{city}, #{state}"
  end
end
