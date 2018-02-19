class Api::V1::Auth::PasswordsController < Api::V1::BaseController
  before_action :authenticate_user!, only: [:update]
  before_action :set_user, only: [:update]
  skip_after_action :build_response_headers, only: [:create]

  def create
    params.require(:email)
    reset_password(params[:email])
  end

  def update
    @user.update_with_password!(password_chage_params)
  end

  private

  def password_recovery_params
    params.require(:email)
    params.permit(:email)
  end

  def password_chage_params
    params.permit(:current_password, :password, :password_confirmation)
  end

  def set_user
    @user = @current_resource
  end
end