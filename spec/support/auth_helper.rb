# frozen_string_literal: true

module AuthHelper
  def auth_headers(user)
    payload = { user_id: user.id }
    token = JWT.encode(payload, Rails.application.secrets.secret_key_base)

    {
      'Authorization' => "Bearer #{token}",
      'Content-Type' => 'application/json'
    }
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
