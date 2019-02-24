class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request, only: :create

  def create
    user = User.create!(user_params)
    auth_token = AuthenticateUser.call(user.email, user.password).result
    render json: { auth_token: auth_token }, status: :created
  rescue ActiveRecord::RecordInvalid => invalid
    render json: { error: invalid.record.errors }, status: :bad_request
  end

  def update
    current_user.update_attributes!(user_params)
    render json: current_user.reload, status: :ok
  rescue ActiveRecord::RecordInvalid => invalid
    render json: { error: invalid.record.errors }, status: :bad_request
  end

  def show
    render json: current_user, status: :ok
  end

  private

  def user_params
    params.permit(
        :name,
        :email,
        :password,
        :password_confirmation,
        :manager
    )
  end
end
