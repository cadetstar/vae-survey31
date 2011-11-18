class AddTemplateFieldsToThankYouCards < ActiveRecord::Migration
  def change
    add_column :thank_you_cards, :template, :text
  end
end
