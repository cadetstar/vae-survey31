class RenameProperyCharLimitField < ActiveRecord::Migration
  def up
    rename_column :seasons, :propery_char_limit, :property_char_limit
  end

  def down
    rename_column :seasons, :property_char_limit, :propery_char_limit
  end
end
