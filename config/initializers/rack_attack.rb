class Rack::Attack

  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Allow all local traffic
  Rack::Attack.safelist('allow-localhost') do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  # Allow an IP address to make 5 requests every 5 seconds
  Rack::Attack.throttle("requests by ip", limit: 5, period: 2) do |request|
    request.ip
  end

  # Throttle login attempts for a given email parameter to 6 reqs/minute
  # Return the email as a discriminator on POST /login requests
  Rack::Attack.throttle('limit logins per email', limit: 6, period: 60) do |req|
    if req.path == 'users/login' && req.post?
      req.params['email']
    end
  end

  # Send the following response to throttled clients
  self.throttled_response = ->(env) {
    retry_after = (env['rack.attack.match_data'] || {})[:period]
    [
      429,
      {'Content-Type' => 'application/json', 'Retry-After' => retry_after.to_s},
      [{error: "Throttle limit reached. Retry later."}.to_json]
    ]
  }
end

