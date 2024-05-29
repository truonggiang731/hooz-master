# frozen_string_literal: true

module JwtAuth
  module SessionHelper
    module_function

    def expire_at
      Time.now.utc + JwtAuth.refresh_token_validity
    end

    def generate_refresh_token
      SecureRandom.urlsafe_base64
    end

    def create_login!(user_id)
      refresh_token = generate_refresh_token
      access_token = JwtAuth::JsonWebToken.encode(user_id)
      Session.create!(user_id:, refresh_token:, access_token:, expire_at:)
    end

    def update_login!(login)
      access_token = JwtAuth::JsonWebToken.encode(login.user_id)
      login.update!(access_token:)
      login
    end
  end
end
