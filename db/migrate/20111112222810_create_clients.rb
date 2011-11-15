class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.integer :company_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :salutation
      t.string :phone
      t.string :r2_client_id
      t.integer :property_id

      t.timestamps
    end
  end
end
