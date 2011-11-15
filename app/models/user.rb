class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :registerable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :inactive,
                  :last_name, :username, :receive_email_restriction, :do_not_receive_flagged, :roles

  has_many :user_properties
  has_many :properties, :through => :user_properties

  has_many :managed_properties, :class_name => "Property", :foreign_key => :manager_id
  has_many :supervised_properties, :class_name => "Property", :foreign_key => :supervisor_id

  ROLES = %w(administrator email_admin)

  def self.list_for_select
    User.order("last_name, first_name").all.collect{|u| [u, u.id]}
  end

  def all_properties
    (self.properties.all + self.managed_properties.all + self.all_supervised_properties.all).uniq
  end

  def all_supervised_properties
    self.supervised_properties.collect{|sp| [sp] + (sp.manager == self ? [nil] : sp.manager.all_supervised_properties)}.flatten.compact.uniq
  end

  def my_properties
    (self.properties.all + self.managed_properties.all).uniq
  end

  def to_s
    self.name_std
  end

  def name_std
    [self.first_name, self.last_name].compact.join(" ")
  end

  def name_lnf
    "#{self.last_name}, #{self.first_name}"
  end

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map {|r| 2**ROLES.index(r)}.sum
  end

  def roles
    ROLES.reject{ |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero?}
  end

  def has_role?(role)
    self.roles.include?(role.to_s)
  end

  def admin?
    self.has_role?(:administrator)
  end

  def email_admin?
    self.has_role?(:email_admin)
  end

  def enabled
    !self.inactive?
  end

  def active_for_authentication?
    self.enabled
  end

  def inactive_message
    "Your account is not active.  Please contact #{$ADMINS[:primary][:name]}."
  end
end
