class CreatePropSeasons < ActiveRecord::Migration
  def change
    create_table :prop_seasons do |t|
      t.integer :property_id
      t.integer :season_id
      t.text :property_pre_text
      t.text :property_post_text
      t.text :property_signoff

      t.timestamps
    end
  end
end
