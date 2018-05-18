class ApplicationMailer < ActionMailer::Base
  default from: "notifications@andela.com"
  layout "mailer", except: :notify_access_token
end
