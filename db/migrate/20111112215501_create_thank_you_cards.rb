class CreateThankYouCards < ActiveRecord::Migration
  def change
    create_table :thank_you_cards do |t|
      t.integer :client_id
      t.integer :prop_season_id
      t.text :greeting
      t.string :passcode
      t.datetime :sent_at

      t.timestamps
    end
  end
end
