class Client < ActiveRecord::Base
  belongs_to :company
  belongs_to :property

  has_many :cifs
  has_many :thank_you_cards

  validates_presence_of :company_id

  before_save :update_property

  def self.search_field
    "last_name"
  end

  def to_s
    name_std
  end

  def name_std
    [self.first_name, self.last_name].compact.join(" ")
  end

  def full_salutation
    [self.salutation, self.name_std].compact.join(" ")
  end

  def update_property
    self.property_id = self.company.property_id if self.company
  end

  def multiple_surveys?
    self.cifs.where(:end_date => (1.month.ago..Time.now)).count > 1
  end
end
