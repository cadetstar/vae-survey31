class ChangeNextMeetingToDatefield < ActiveRecord::Migration
  def up
    change_column :cifs, :next_meeting, :datetime
  end

  def down
  end
end
