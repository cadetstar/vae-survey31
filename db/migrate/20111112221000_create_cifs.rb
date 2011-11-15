class CreateCifs < ActiveRecord::Migration
  def change
    create_table :cifs do |t|
      t.integer :client_id
      t.integer :thank_you_card_id
      t.text :answers
      t.text :client_comments
      t.integer :creator_id
      t.integer :approver_id
      t.integer :property_id
      t.datetime :sent_at
      t.datetime :completed_at
      t.datetime :start_date
      t.datetime :end_date
      t.text :location
      t.text :notes
      t.string :passcode
      t.string :number_of_meetings
      t.string :next_meeting
      t.boolean :please_contact
      t.string :submittor
      t.string :contact_info
      t.boolean :count_survey
      t.string :r2_order_id
      t.boolean :cif_captured, :default => false
      t.datetime :clicked_at
      t.boolean :had_si
      t.boolean :had_ar
      t.boolean :had_ptt
      t.integer :flagger_id
      t.datetime :flagged_until
      t.text :flag_comment
      t.text :employee_comments
      t.integer :overall_satisfaction

      t.timestamps
    end
  end
end
