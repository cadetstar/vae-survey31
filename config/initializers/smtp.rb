VaeSurvey31::Application.config.action_mailer.delivery_method = :smtp
VaeSurvey31::Application.config.action_mailer.smtp_settings = {
    :address => "mail.vaecorp.com",
    :port => 8889,
    :domain => "vaecorp.com",
    :authentication => :login,
    :user_name => "thankyou@vaecorp.com",
    :password => "V@3cs1IT"
}
