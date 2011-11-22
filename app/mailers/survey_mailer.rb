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
            :password => "V@3cs1IT"
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
    @cif = cif
    mail(:to => "#{cif.client.email}", :subject => @subject, :from => "#{cif.property.manager} <#{cif.property.manager.email}>") do |format|
      format.text
      format.html
    end
  end

  def flagged_survey(cif, user)
    load_settings 'vaecorp'
    mail(:to => user.email, :subject => '[VAE Survey Site] A survey has been flagged.') do |format|
      format.html {render :text => "A survey for your property has been flagged.  Please click on the following link to edit the survey: #{link_to edit_cif_url(@cif, :only_path => false)}<br /><br />Note from administrator:<br />#{@cif.flagged_comment}"}
      format.text {render :text => "A survey for your property has been flagged.  Please click on the following link to edit the survey: #{link_to edit_cif_url(@cif, :only_path => false)}\n\nNote from administrator:\n#{@cif.flagged_comment}"}
    end
  end

  def survey_response(cif, user)
    load_settings 'vaecorp'
    mail(:to => user.email, :subject => "[VAE Survey Site] A survey has been received for #{cif.property}")
  end

  def thank_you_email(manager, tyc)
    setup_remote_email(manager, tyc)
    insert_inline_image(tyc)

    mail do |format|
      format.text { render :text => parse_email_template(tyc.season.email_template, tyc)}
      format.html { render :text => parse_email_template(tyc.season.email_template_plain, tyc)}
    end
  end

  def general_message(user, subject, body)
    load_settings 'vaecorp'
    mail(:to => user.email, :subject => subject) do |format|
      format.html {render :text => body}
      format.text {render :text => body}
    end
  end

  def season_sent(user, name, number, list)
    mail(:to => user.email, :subject => "[VAE Survey System] Sent Emails Summary for #{name}") do |format|
      format.html {render :text => "<p>I have finished sending a set of emails for the #{name} season.  Total emails sent: #{number}</p><p>#{list.join("<br />")}</p>"}
      format.text {render :text => "I have finished sending a set of emails for the #{name} season.  Total emails sent: #{number}\n\n#{list.join(/\n/)}"}
    end
  end

  def error_message(exception, trace, session, params, env, account, is_live = false, sent_on = Time.now)
    load_settings('vaecorp')
    @recipients    = 'cadetstar@hotmail.com'
    @from          = 'Survey System <survey@vaecorp.com>'
    @subject       = "Error message: #{env['REQUEST_URI']}"
    @sent_on       = sent_on
    @content_type = "text/html"
    @exception = exception
    @trace = trace
    @session = session
    @params = params
    @env = env
    @account = account

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
    attachments.inline["card#{tyc.id}.jpg"] = File.read(File.join(Rails.root.to_s,'files','images',"#{tyc.id}.jpg"))
  end

  def parse_email_template(body, tyc)
    new_body = body.clone
    new_body.gsub!(/%FULL_SALUTATION%/, tyc.client.full_salutation)
    new_body.gsub!(/%CID%/, image_tag(attachments["card#{tyc.id}.jpg"].url))
    new_body.gsub!(/%PLAIN_TEXT_INSERT%/,"#{tyc.season.pre_text}#{if tyc.prop_season.property_pre_text then '\n\n'+tyc.prop_season.property_pre_text end}#{if tyc.greeting then '\n\n'+tyc.greeting end}#{if tyc.prop_season.property_post_text then '\n\n'+tyc.prop_season.property_post_text end}\n\n#{tyc.season.post_text}")
    new_body.gsub!(/%PROPERTY_SIGNOFF%/,tyc.prop_season.property_signoff)
    new_body.gsub!(/%GREETING_URL%/,"http://#{$CUR_SITE}/thank_you_cards/#{tyc.id}/#{tyc.passcode}/view")
    new_body
  end

end
