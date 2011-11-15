class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.string :name
      t.text :subject
      t.text :pre_text
      t.text :post_text
      t.integer :propery_char_limit
      t.boolean :enabled
      t.datetime :when_email

      t.timestamps
    end
  end
end
