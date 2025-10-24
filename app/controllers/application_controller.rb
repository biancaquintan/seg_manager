class ApplicationController < ActionController::API
  before_action :authorize_request

  private

  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    decoded = decode_token(header)
    @current_user = User.find(decoded[:user_id])
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { errors: 'Unauthorized' }, status: :unauthorized
  end

  def decode_token(token)
    decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
    HashWithIndifferentAccess.new decoded
  end
end
