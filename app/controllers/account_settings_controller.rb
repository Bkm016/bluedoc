# frozen_string_literal: true

class AccountSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
  end

  def account
  end

  def update
    case params[:_by]
    when "password"
      update_password
    when "profile"
      update_profile
    when "username"
      update_username
    end
  end

  def destroy
    @user.destroy
    sign_out @user
    redirect_to root_path
  end

  private

  def set_user
    @user = current_user
  end

  def update_password
    password_params = params.require(:user).permit(:current_password, :password, :password_confirmation)
    if @user.update_password(password_params)
      bypass_sign_in @user
      redirect_to account_account_settings_path, notice: t(".You have successfully changed your password")
    else
      render :account
    end
  end

  def destroy_password
    @user.destroy_password
  end

  def update_profile
    if @user.update(user_params)
      redirect_to account_settings_path, notice: t(".You have successfully updated your profile", locale: set_locale)
    else
      render :show
    end
  end

  def update_username
    if user_params[:slug] == @user.slug
      return render :account
    end

    if @user.update(slug: user_params[:slug])
      redirect_to account_account_settings_path, notice: t(".You have successfully changed your username")
    else
      render :account
    end
  end

  def user_params
    params.require(:user).permit(:slug, :name, :email, :avatar, :description, :location, :url, :locale)
  end

  def password_params
  end
end
