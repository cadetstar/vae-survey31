class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.text :results
      t.text :parameters
      t.string :filename
      t.boolean :completed
      t.boolean :download
      t.string :type_of_report

      t.timestamps
    end
  end
end
