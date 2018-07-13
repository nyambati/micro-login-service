require "jwt"

class JsonWebToken
  @rsa_private = if Rails.env.production? || Rails.env.staging? || Rails.env.sandbox?
                   OpenSSL::PKey::RSA.new(ENV["PRIVATE_KEY"].gsub("\\n", "\n"))
                 else
                   OpenSSL::PKey::RSA.generate 2048
                 end

  @rsa_public = @rsa_private.public_key

  def self.encode(payload, exp = 7.days.from_now)
    payload[:exp] = exp.to_i
    payload.reverse_merge!(meta)
    JWT.encode payload, @rsa_private, "RS256"
  end

  def self.decode(token)
    JWT.decode token, @rsa_public, true, algorithm: "RS256"
  end

  def self.valid_payload(payload)
    if expired(payload) || payload["iss"] != meta[:iss] || payload["aud"] != meta[:aud]
      false
    else
      true
    end
  end

  def self.meta
    {
      exp: 14.days.from_now.to_i,
      iss: "andela",
      aud: "client"
    }
  end

  def self.expired(payload)
    Time.at(payload["exp"]) < Time.now
  end
end
