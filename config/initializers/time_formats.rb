Time::DATE_FORMATS[:default] = "%m/%d/%Y %I:%M%p %Z"
Time::DATE_FORMATS[:date_time12] = "%m/%d/%Y %I:%M%p %Z"
Time::DATE_FORMATS[:shortdate] = "%m/%d/%Y"
Time::DATE_FORMATS[:file_date] = "%m-%d-%Y--%I%M%p"

class Time
  def to_s(format = :default)
    if self.utc?
      to_formatted_s(format)
    else
      self.in_time_zone("Eastern Time (US & Canada)").to_s(format)
    end
  end
end