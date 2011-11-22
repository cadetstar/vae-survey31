# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111122015823) do

  create_table "cifs", :force => true do |t|
    t.integer  "client_id"
    t.integer  "thank_you_card_id"
    t.text     "answers"
    t.text     "client_comments"
    t.integer  "creator_id"
    t.integer  "approver_id"
    t.integer  "property_id"
    t.datetime "sent_at"
    t.datetime "completed_at"
    t.datetime "start_date"
    t.datetime "end_date"
    t.text     "location"
    t.text     "notes"
    t.string   "passcode"
    t.string   "number_of_meetings"
    t.boolean  "please_contact"
    t.string   "submittor"
    t.string   "contact_info"
    t.boolean  "count_survey"
    t.string   "r2_order_id"
    t.boolean  "cif_captured",         :default => false
    t.datetime "clicked_at"
    t.boolean  "had_si"
    t.boolean  "had_ar"
    t.boolean  "had_ptt"
    t.integer  "flagger_id"
    t.datetime "flagged_until"
    t.text     "flag_comment"
    t.text     "employee_comments"
    t.integer  "overall_satisfaction"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "next_meeting"
    t.float    "average_score"
  end

  create_table "clients", :force => true do |t|
    t.integer  "company_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "salutation"
    t.string   "phone"
    t.string   "r2_client_id"
    t.integer  "property_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "r2_company_id"
    t.integer  "property_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prop_seasons", :force => true do |t|
    t.integer  "property_id"
    t.integer  "season_id"
    t.text     "property_pre_text"
    t.text     "property_post_text"
    t.text     "property_signoff"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "properties", :force => true do |t|
    t.string   "code"
    t.string   "r2_code"
    t.string   "name"
    t.integer  "manager_id"
    t.integer  "supervisor_id"
    t.integer  "group_id"
    t.boolean  "cif_include"
    t.string   "cif_form"
    t.boolean  "do_not_send_surveys_for_property"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", :force => true do |t|
    t.text     "results"
    t.text     "parameters"
    t.string   "filename"
    t.boolean  "completed"
    t.boolean  "download"
    t.string   "type_of_report"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "seasons", :force => true do |t|
    t.string   "name"
    t.text     "subject"
    t.text     "pre_text"
    t.text     "post_text"
    t.integer  "property_char_limit"
    t.boolean  "enabled"
    t.datetime "when_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "email_template"
    t.text     "email_template_plain"
    t.text     "template"
  end

  create_table "thank_you_cards", :force => true do |t|
    t.integer  "client_id"
    t.integer  "prop_season_id"
    t.text     "greeting"
    t.string   "passcode"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_properties", :force => true do |t|
    t.integer  "property_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                    :default => "",    :null => false
    t.string   "encrypted_password",        :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                            :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "receive_email_restriction"
    t.boolean  "do_not_receive_flagged",                   :default => false
    t.boolean  "inactive",                                 :default => false
    t.integer  "roles_mask"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
