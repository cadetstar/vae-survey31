class MoveTemplateFieldToSeason < ActiveRecord::Migration
  def up
    remove_column :thank_you_cards, :template
    add_column :seasons, :template, :text
  end

  def down
    remove_column :seasons, :template
    add_column :thank_you_cards, :template, :text
  end
end
