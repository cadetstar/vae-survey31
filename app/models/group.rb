class Group < ActiveRecord::Base
  has_many :properties

  validates_uniqueness_of :name

  before_destroy :check_assigned_properties

  def to_s
    name
  end

  def any_active
    self.properties.select{|r| r.cif_include}.size > 0
  end

  def report_property_codes
    self.properties.select{|r| r.cif_include}.collect{|r| r.code}.join("/")
  end

  def check_assigned_properties
    self.properties.size == 0
  end
end
