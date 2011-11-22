require 'spreadsheet'

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
                 'client_num_meetings' => 'number_of_meetings',
                 'client_next_meeting' => 'next_meeting',
                 'client_please_contact' => 'please_contact',
                 'client_submittor' => 'submittor',
                 'client_contact_info' => 'contact_info',
                 'csi_had_si' => 'had_si',
                 'csi_had_ar' => 'had_ar',
                 'csi_had_ptt' => 'had_ptt',
                 'key_score' => 'overall_satisfaction',
                 'flagged_by' => 'flagger_id',
                 'client_emp_comments' => 'employee_comments',
                 'created_by' => 'creator_id'
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
                  'receive_flagged' => 'do_not_receive_flagged',
                  'crypted_password' => 'encrypted_password'
      }
  }

  SKIPS = %w(schema_migrations offlinereports sessions permissions roles)

  tables = %w(assignments cif_aggregates cifs clients companies properties propseasons roles seasons thankyous users)

  tables.each do |table|
    #%w(cifs propseasons).each do |table|
    next if SKIPS.include? table

    klass = Class.new(ActiveRecord::Base)
    klass.class_eval do
      set_table_name table
      establish_connection(Rails.configuration.database_configuration["mssql"])
    end

    new_table = TABLE_MAP[table] || table
    new_model = new_table.classify.constantize

#    klass.limit(500).all.each do |row|
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

      if new_table == 'thank_you_cards'
        new_model.skip_callback(:save, :after, :update_pdf_and_jpeg)
      elsif new_table == 'users'
        new_data['password'] = 'vaecorp'
        new_data['password_confirmation'] = 'vaecorp'
      elsif new_table == 'properties'
        new_data['cif_form'] = Cif::FORMS[%w(VAE CONV FR CSI).index(new_data['cif_form'])] || Cif::FORMS.first
        new_data['r2_code'] = new_data['code'].gsub(/[^\d]/,'')
      end
      puts "Converting #{table} - #{row['id']}"
      unless new_model.find_by_id(row['id'])
        new_model.create! do |m|
          new_data.each do |k,v|
            m.send("#{k}=",v)
          end
        end
      end

      if new_table == 'thank_you_cards'
        new_model.set_callback(:save, :after, :update_pdf_and_jpeg)
      end
      new_model.connection.execute "ALTER SEQUENCE #{new_table}_id_seq RESTART WITH #{new_model.order('id desc').first.id+1}"
    end
  end

  klass = Class.new(ActiveRecord::Base)
  klass.class_eval do
    set_table_name 'permissions'
    establish_connection(Rails.configuration.database_configuration["mssql"])
  end

  role_mapper = {1 => 'administrator', 2 => 'email_admin'}

  User.all.each do |user|
    valid = []
    klass.find_all_by_user_id(user.id).each do |k|
      if j = role_mapper[k['role_id'].to_i]
        valid << j
      end
    end
    valid.uniq!
    user.roles = valid
    user.save
  end
end

desc "Send Emails for all Valid Seasons"
task :send_emails => :environment do
  Season.where(:enabled => true).each do |season|
    list_of_people = []
    ThankYouCard.where(:prop_season => season.prop_seasons).where("sent_at IS NULL").limit(100).each do |tyc|
      if tyc.email.match(/\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/)
        begin
          SurveyMailer.thank_you_email(tyc.property.manager, tyc).deliver
          tyc.update_attribute(:sent_at, Time.now)
          list_of_people << tyc.client.to_s
        rescue Net::SMTPFatalError, Net::SMTPServerBusy, Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError => e
          User.with_role('email_admin').each do |user|
            SurveyMailer.general_message(user, 'Problem with email address', "There was a problem with the following address: #{tyc.client.client_email} for client #{tyc.client.name_std}/#{tyc.client.id}.  I could not send their Holiday Card or Thank You Card.").deliver
          end
        end
      end
    end

    if list_of_people.size > 0
      User.with_role('email_admin').each do |user|
        SurveyMailer.season_sent(user, season.name, list_of_people.size, list_of_people)
      end
    end
    puts "I ran for season #{season} at #{Time.now.to_s(:date_time12)}."
  end
end

desc "Process Output from R2"
task :process_r2 => :environment do
  STATE_LIST = [['Alabama', 'AL'],['Alaska', 'AK'],['Arizona', 'AZ'],['Arkansas', 'AR'],['California', 'CA'],['Colorado', 'CO'],['Connecticut', 'CT'],['Delaware', 'DE'],['District of Columbia', 'DC'],['Florida', 'FL'],['Georgia', 'GA'],['Hawaii', 'HI'],['Idaho', 'ID'],['Illinois', 'IL'],['Indiana', 'IN'],['Iowa', 'IA'],['Kansas', 'KS'],['Kentucky', 'KY'],['Louisiana', 'LA'],['Maine', 'ME'],['Maryland', 'MD'],['Massachusetts', 'MA'],['Michigan', 'MI'],['Minnesota', 'MN'],['Mississippi', 'MS'],['Missouri', 'MO'],['Montana', 'MT'],['Nebraska', 'NE'],['Nevada', 'NV'],['New Hampshire', 'NH'],['New Jersey', 'NJ'],['New Mexico', 'NM'],['New York', 'NY'],['North Carolina', 'NC'],['North Dakota', 'ND'],['Ohio', 'OH'],['Oklahoma', 'OK'],['Oregon', 'OR'],['Pennsylvania', 'PA'],['Rhode Island', 'RI'],['South Carolina', 'SC'],['South Dakota', 'SD'],['Tennessee', 'TN'],['Texas', 'TX'],['Utah', 'UT'],['Vermont', 'VT'],['Virginia', 'VA'],['Washington', 'WA'],['West Virginia', 'WV'],['Wisconsin', 'WI'],['Wyoming', 'WY'],['Alberta','AB'],['British Columbia','BC'],['Manitoba','MB'],['New Brunswick','NB'],['Newfoundland and Labrador','NL'],['Northwest Territories','NT'],['Nova Scotia','NS'],['Nunavut','NU'],['Ontario','ON'],['Prince Edward Island','PE'],['Quebec','QC'],['Saskatchewan','SK'],['Yukon','YT'],['United States','USA'],['Canada','CAN']]


  mylog = File.new(File.join(Rails.root.to_s, 'log','imports',"#{Time.now.strftime("%Y-%m-%d")}.txt"), 'a')
  mylog.puts "Starting to process R2 files at #{Time.now.to_s(:date_time12)}."

  files = Dir.glob(File.join(Rails.root.to_s, 'files','incoming','*.xls'))
  system_user = User.find_or_create_by_username('system')

  files.each do |filename|
    mylog.puts "Trying to load #{filename}"
    f = File.new(filename, 'rb+')
    book = Spreadsheet.open f
    sheet = book.worksheet 0
    sheet.each do |row|
      next if row[0] == 'INVOICEID'

      if row[19] or !Cif.find_by_r2_order_id(row[1])
        mylog.puts "Initial Order not found."
        property = Property.find_by_r2_code(row[11]) || Property.find_or_create_by_r2_code('5217-96', :name => "Information Technology")

        unless client = Client.find_by_r2_client_id_and_property_id(row[14], property.id)
          unless company = Company.find_by_r2_company_id_and_property_id(row[13], property.id)
            state = (STATE_LIST.rassoc(row[17].to_s.upcase) || STATE_LIST.assoc(row[17].to_s.capitalize) || [1,row[17]])[1]
            company = Company.create(:name => row[3], :address_line_1 => row[15].split(/\n/)[0], :address_line_2 => (row[15].split(/\n/).size > 1 ? row[15].split(/\n/)[1..-1].join(/\n/) : ''), :city => row[16], :state => state, :zip => row[18], :r2_company_id => row[13], :property_id => property.id)
          end
          client = Client.create(:company_id => company.id, :first_name => (row[4].blank? ? 'Contact' : row[4].split(/ /)[0..-2].to_s), :last_name => (row[4].blank? ? 'Name' : row[4].split(/ /)[-1..-1]), :email => row[5], :phone => row[6], :r2_client_id => row[14], :property_id => property.id)
        end

        unless Cif.find_by_r2_order_id_and_client_id(row[19]||row[1],client.id)
          puts "Processing #{row[1]} - #{row[7]} - Adding Order."
          mylog.puts "Processing #{row[1]} - #{row[7]} - Adding Order."
          Cif.create(:client_id => client.id, :creator_id => system_user.id, :property_id => property.id, :start_date => ((row[19] ? row[20] : row[9]) + 6.hours), :end_date => ((row[19] ? row[21] : row[10]) + 6.hours), :location => row[8], :r2_order_id => (row[19] || row[1]), :notes => row[22])
        else
          puts "Process #{row[1]} - #{row[7]} - Already in system."
          mylog.puts "Process #{row[1]} - #{row[7]} - Already in system."
        end
      else
        puts "Process #{row[1]} - #{row[7]} - Already in system."
        mylog.puts "Process #{row[1]} - #{row[7]} - Already in system."
      end
    end
    f.close
  end
  mylog.close
end

desc "Send Flag Reminders"
task :send_flags => :environment do
  Cif.where(['flagged_until between ? and ? or flagged_until between ? and ? or flagged_until between ? and ?', 1.days.from_now, 2.days.from_now, 3.days.from_now, 4.days.from_now, 5.days.from_now, 6.days.from_now]).each do |cif|
    users = cif.property.users + [cif.property.manager]
    users.uniq!

    users.each do |user|
      begin
        SurveyMailer.flagged_survey(cif, user).deliver if user.receive_flags?
      rescue Net::SMTPFatalError => e
        # Not actually doing anything
      rescue Net::SMTPServerBusy, Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError => e
        # Not actually doing anything
      end
    end
  end
end
