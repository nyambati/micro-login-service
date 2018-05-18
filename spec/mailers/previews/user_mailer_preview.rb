class UserMailerPreview < ActionMailer::Preview
  def invitation_mail
    user = User.first
    UserMailer.invitation_mail(user)
  end

  def forgot_mail
    user = User.first
    UserMailer.forgot_mail(user)
  end
end
