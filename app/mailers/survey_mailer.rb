class SurveyMailer < ActionMailer::Base
  default from: "thankyou@vaecorp.com"

  def load_settings(site)
    case site
      when 'conferencesystems' then
        @@smtp_settings = {
            :address => 'mail.conferencesystems.com',
            :port => 26,
            :domain => 'conferencesystems.com',
            :authentication => :login,
            :user_name => 'thankyou@conferencesystems.com',
            :password => '129101701'
        }
      else
        @@smtp_settings = {
            :address => "mail.vaecorp.com",
            :port => 8889,
            :domain => "vaecorp.com",
            :authentication => :login,
            :user_name => "thankyou@vaecorp.com",
            :password => "129101701"
        }
    end
  end

  def survey_email(cif)
    case cif.property.cif_form
      when 'csi'
        load_settings('conferencesystems')
        @subject = "CSI's Services at Your Recent Event"
      when 'vae_french'
        load_settings('vaecorp')
        @subject = 'Votre reunion recente'
      else
        load_settings('vaecorp')
        @subject = "VAE's Services at Your Recent Event"
    end
    @recipients = "#{cif.client.email}"
    @sent_on = Time.now
    @content_type = "multipart/related"

    @from = "#{cif.property.manager} <#{cif.property.manager.email}>"

    part "text/plain" do |r|
      r.body = render_message("survey_email_#{cif.cif_form}_plain", :cif => cif)
      r.transfer_encoding = 'base64'
    end

    part :content_type => "text/html", :body => render_message("survey_email_#{cif.cif_form}_html", :cif => cif)
  end

  def flagged_survey(cif, user)

  end

  def survey_response(cif, user)

  end

  def thank_you_email(manager, tyc)
    setup_remote_email(manager, tyc)
    insert_inline_image(tyc)

    part :content_type => "text/html", :body => parse_email_template(tyc.season.email_template, tyc)
    part "text/plain" do |r|
      r.body = parse_email_template(tyc.season.email_template_plain, tyc)
      r.transfer_encoding = 'base64'
    end
  end

  def general_message(user, subject, body)

  end

  def season_sent(user, name, number, list)

  end

  protected

  def setup_email(user)
    load_settings('vaecorp')
  end

  def setup_remote_email(user, tyc)
    if user.email.include?('conferencesystems')
      load_settings('conferencesystems')
    else
      load_settings('vaecorp')
    end
    @recipients = "#{tyc.client.email}"
    @from       = "#{user} <#{user.email}>"
    @subject    = "#{tyc.season.subject}"
    @sent_on    = Time.now
    @content_type = "multipart/related"
  end

  def insert_inline_image(tyc)
    @cid[1] = "card#{tyc.id}.jpg@vaecorp.com"

    f = File.open(File.join(Rails.root.to_s,'files','images',"#{tyc.id}.jpg",'rb'))

    inline_attachment   :content_type => "image/jpg",
                        :body => f.read,
                        :filename => "card#{tyc.id}.jpg",
                        :cid => "<#{@cid[1]}>"
  end

  def parse_email_template(body, tyc)
    new_body = body.clone
    new_body.gsub!(/%FULL_SALUTATION%/, tyc.client.full_salutation)
    new_body.gsub!(/%CID%/, @cid[1])
    new_body.gsub!(/%PLAIN_TEXT_INSERT%/,"#{tyc.season.pre_text}#{if tyc.prop_season.property_pre_text then '\n\n'+tyc.prop_season.property_pre_text end}#{if tyc.greeting then '\n\n'+tyc.greeting end}#{if tyc.prop_season.property_post_text then '\n\n'+tyc.prop_season.property_post_text end}\n\n#{tyc.season.post_text}")
    new_body.gsub!(/%PROPERTY_SIGNOFF%/,tyc.prop_season.property_signoff)
    new_body.gsub!(/%GREETING_URL%/,"http://#{$CUR_SITE}/thank_you_cards/#{tyc.id}/#{tyc.passcode}/view")
    new_body
  end

end
