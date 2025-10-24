# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authorize_request, only: [:login]

      # POST /api/v1/login
      def login
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          token = encode_token({ user_id: user.id })
          render json: { token: token }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      private

      def encode_token(payload)
        JWT.encode(payload, Rails.application.secrets.secret_key_base)
      end
    end
  end
end
