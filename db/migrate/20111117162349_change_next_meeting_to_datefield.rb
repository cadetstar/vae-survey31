class ChangeNextMeetingToDatefield < ActiveRecord::Migration
  def up
    remove_column :cifs, :next_meeting
    add_column :cifs, :next_meeting, :datetime
  end

  def down
  end
end
