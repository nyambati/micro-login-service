module GenerateToken
  def self.generate_and_send_token_to(user, type = "invitation")
    token = user.confirmation_token_digest
    user.confirmation_token_digest = Digest::SHA512.hexdigest(token)
    user.save
    if type == "forgot"
      UserMailer.with(user: user, token: token).forgot_mail.deliver_later
    else
      UserMailer.with(user: user, token: token).invitation_mail.deliver_later
    end
    token
  end
end
