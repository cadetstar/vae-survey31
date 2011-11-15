class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.string :code
      t.string :r2_code
      t.string :name
      t.integer :manager_id
      t.integer :supervisor_id
      t.integer :group_id
      t.boolean :cif_include
      t.string :cif_form
      t.boolean :do_not_send_surveys_for_property

      t.timestamps
    end
  end
end
