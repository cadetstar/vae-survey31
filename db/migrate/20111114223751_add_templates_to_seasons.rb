class AddTemplatesToSeasons < ActiveRecord::Migration
  def change
    add_column :seasons, :email_template, :text
    add_column :seasons, :email_template_plain, :text
  end
end
