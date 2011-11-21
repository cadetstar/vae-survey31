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
      }
  }

  SKIPS = %w(schema_migrations offlinereports sessions)

#  old_connection.tables.each do |table|
  %w(propseasons).each do |table|
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
            new_data[COLUMN_MAP[table][k]||k] = v
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

    end

  end
end
