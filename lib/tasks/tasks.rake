desc "Convert from MSSQL to Postgres"
task :mssql_convert => :environment do
  TABLE_MAP = {
      "propseasons" => "prop_seasons",
      "assignments" => "user_properties",
      "cif_aggregates" => "groups",
      "thankyous" => "thank_you_cards",

  }

  COLUMN_MAP = {
      "cif_aggregates" => {"agg_name" => "name"},
      "cifs" => {"thankyou_id" => "thank_you_card_id",
                 "question1" => "answers",
                 "question2" => "answers",
                 "question3" => "answers",
                 "question4" => "answers",
                 "question5" => "answers",
                 "question6" => "answers",
                 "question7" => "answers",
                 "question8" => "answers",
                 "question9" => "answers",
                 "question10" => "answers",
                 "question11" => "answers",
                 "question12" => "answers",
                 "question13" => "answers",
                 "question14" => "answers",
                 "question15" => "answers",
                 "question16" => "answers",
                 "approved_by" => "approver_id",
                 'startdate' => 'start_date',
                 'enddate' => 'end_date',
                 'cif_passcode' => 'passcode',
                 'client_num_meeting' => 'number_of_meetings',
                 'client_next_meeting' => 'next_meeting',
                 'client_please_contacct' => 'please_contact',
                 'client_submittor' => 'submittor',
                 'client_contact_info' => 'contact_info',
                 'csi_had_si' => 'had_si',
                 'csi_had_ar' => 'had_ar',
                 'csi_had_ptt' => 'had_ptt',
                 'key_score' => 'overall_satisfaction',
                 'flagged_by' => 'flagger_id',
                 'client_emp_comments' => 'employee_comments'
      },
      'propseasons' => {'prop_pre_text' => 'property_pre_text',
                        'prop_post_text' => 'property_post_text',
                        'prop_signoff' => 'property_signoff'
      },
      'clients' => {'client_firstname' => 'first_name',
                    'client_lastname' => 'last_name',
                    'client_email' => 'email',
                    'client_salutation' => 'salutation',
                    'client_phone' => 'phone'
      },
      'companies' => {'company_name' => 'name',
                      'company_addr1' => 'address_line_1',
                      'company_addr2' => 'address_line_2',
                      'company_city' => 'city',
                      'company_state' => 'state',
                      'company_zip' => 'zip'
      },
      'properties' => {'property_code' => 'code',
                       'property_name' => 'name',
                       'cifaggregate_id' => 'group_id'
      },
      'seasons' => {'season_name' => 'name',
                    'season_subject' => 'subject',
                    'season_pre_text' => 'pre_text',
                    'season_post_text' => 'post_text',
                    'season_when_email' => 'when_email',
                    'season_prop_char_limit' => 'property_char_limit',
                    'season_enabled' => 'enabled'
      },
      'thankyous' => {'propseason_id' => 'prop_season_id',
                      'ty_passcode' => 'passcode',
                      'thankyou_greeting' => 'greeting',
                      'emailsent' => 'sent_at'
      },
      'users' => {'firstname' => 'first_name',
                  'lastname' => 'last_name',
                  'login' => 'username',
                  'salt' => -1,
                  'remember_token' => -1,
                  'remember_token_expires_at' => -1,
                  'activation_code' => -1,
                  'activated_at' => -1,
                  'password_reset_code' => -1,
                  'receive_flagged' => 'do_not_receive_flagged'
      }
  }

  SKIPS = %w(schema_migrations offlinereports sessions permissions roles)

#  old_connection.tables.each do |table|
  %w(cifs propseasons).each do |table|
    next if SKIPS.include? table

    klass = Class.new(ActiveRecord::Base)
    klass.class_eval do
      set_table_name table
      establish_connection(Rails.configuration.database_configuration["mssql"])
    end

    new_table = TABLE_MAP[table] || table
    new_model = new_table.classify.constantize

    klass.all.each do |row|
      new_data = {}
      row.attributes.each do |k,v|
        if COLUMN_MAP[table]
          if COLUMN_MAP[table][k] == 'answers'
            new_data['answers'] ||= {}
            new_data['answers'][k.gsub(/question/,'').to_i] = v
          else
            unless COLUMN_MAP[table][k] == -1
              new_data[COLUMN_MAP[table][k]||k] = v
            end
          end
        else
          new_data[k] = v
        end
      end

      puts "Converting #{table} - #{row['id']}"
      new_model.create! do |m|
        new_data.each do |k,v|
          m.send("#{k}=",v)
        end
      end

      new_model.connection.execute "ALTER SEQUENCE #{new_table}_id_seq RESTART WITH #{new_model.order('id desc').first.id+1}"
    end
  end
end