class Property < ActiveRecord::Base
  belongs_to :manager, :class_name => "User"
  belongs_to :supervisor, :class_name => "User"
  belongs_to :group

  has_many   :prop_seasons
  has_many   :seasons, :through => :prop_seasons
  has_many   :thank_you_cards, :through => :prop_seasons
  has_many   :cifs

  has_many :user_properties
  has_many :users, :through => :user_properties

  before_create :make_group

  def self.list_for_select(user)
    user ||= User.new
    if user.admin?
      Property.order(:code).all.collect{|r| [r, r.id]}
    else
      user.all_properties.collect{|r| [r,r.id]}
    end
  end

  def to_s
    prop_std
  end

  def survey_users
    users = self.caring_users + [self.supervisor]
    unless self.supervisor == self.manager or self.manager.try(:username) == 'dmartin'
      self.supervisor.managed_properties.each do |mp|
        users += mp.survey_users
      end
    end
    users << User.find_by_username('dmartin')
    users.uniq!
    users -= User.find_all_by_username('jcassell')
    users.select{|u| u.enabled}
  end

  def caring_users
    ([self.manager] + self.users).uniq
  end

  def prop_std
    "#{self.code} - #{self.name}"
  end

  def send_surveys?
    !self.do_not_send_surveys_for_property
  end

  def make_group
    unless self.group
      g = Group.find_or_create_by_name(self.name)
      self.group_id = g.id
    end
  end
end
