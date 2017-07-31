class PasswordResetsController < ApplicationController
  before_action :find_user, only: %i(edit update)
  before_action :valid_user, only: %i(edit update)
  before_action :check_expiration, only: %i(edit update)

  attr_reader :user

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if user
      user.create_reset_digest
      user.send_password_reset_email
      flash[:info] = t "reset.sent"
      redirect_to root_url
    else
      flash.now[:danger] = t "reset.not_found"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      password_empty user
    elsif user.update_attributes(user_params)
      reset_success user
    else
      render :edit
    end
  end

  private

  def password_empty user
    user.errors.add :password, t("reset.cant_be_empty")
    render :edit
  end

  def reset_success user
    log_in user
    flash[:success] = t "reset.reset"
    redirect_to user
  end

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def find_user
    @user = User.find_by email: params[:email]
  end

  def valid_user
    unless user && user.activated? && user.authenticated?(:reset,
      params[:id])
      redirect_to root_url
    end
  end

  def check_expiration
    return unless user.password_reset_expired?
    flash[:danger] = t "reset.expired"
    redirect_to new_password_reset_url
  end
end
