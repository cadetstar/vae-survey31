ActionMailer::Base.delivery_method = VaeSurvey31::Application.config.action_mailer.delivery_method = :smtp
ActionMailer::Base.smtp_settings = VaeSurvey31::Application.config.action_mailer.smtp_settings = {
    :address => "mail.vaecorp.com",
    :port => 8889,
    :domain => "vaecorp.com",
    :authentication => :login,
    :user_name => "thankyou@vaecorp.com",
    :password => "V@3cs1IT"
}
