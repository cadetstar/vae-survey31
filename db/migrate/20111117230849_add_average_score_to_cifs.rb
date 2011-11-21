class AddAverageScoreToCifs < ActiveRecord::Migration
  def change
    add_column :cifs, :average_score, :float
  end
end
