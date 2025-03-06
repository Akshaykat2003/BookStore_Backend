class ApplicationController < ActionController::API
  before_action :authenticate_request, except: [:signup, :login]

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header.present?

    decoded_token = JwtService.decode(token)
    if decoded_token
      @current_user = User.find_by(id: decoded_token[:user_id])
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
