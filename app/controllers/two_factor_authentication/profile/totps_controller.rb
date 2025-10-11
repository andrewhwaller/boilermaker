class TwoFactorAuthentication::Profile::TotpsController < ApplicationController
  skip_before_action :enforce_two_factor_setup

  before_action :set_user
  before_action :set_totp, only: %i[ new create ]
  before_action :ensure_can_disable, only: %i[ destroy_confirmation destroy ]

  def new
    render Views::TwoFactorAuthentication::Profile::Totps::New.new(totp: @totp, qr_code: generate_qr_code)
  end

  def create
    if @totp.verify(params[:code], drift_behind: 15)
      @user.update! otp_required_for_sign_in: true
      redirect_to two_factor_authentication_profile_recovery_codes_path
    else
      redirect_to new_two_factor_authentication_profile_totp_path, alert: "That code was not accepted. Please try again."
    end
  end

  def update
    @user.update! otp_secret: ROTP::Base32.random
    redirect_to new_two_factor_authentication_profile_totp_path
  end

  def destroy_confirmation
    render Views::TwoFactorAuthentication::Profile::Totps::DestroyConfirmation.new
  end

  def destroy
    totp = ROTP::TOTP.new(@user.otp_secret, issuer: Boilermaker::Config.app_name)

    if totp.verify(params[:code], drift_behind: 15)
      @user.disable_two_factor!
      redirect_to settings_path, notice: "Two-factor authentication has been disabled."
    else
      flash.now[:alert] = "That code was not accepted. Please try again."
      render Views::TwoFactorAuthentication::Profile::Totps::DestroyConfirmation.new, status: :unprocessable_entity
    end
  end

  private

    def set_user
      @user = Current.user
    end

    def set_totp
      @totp = ROTP::TOTP.new(@user.otp_secret, issuer: Boilermaker::Config.app_name)
    end

    def provisioning_uri
      @totp.provisioning_uri(@user.email)
    end

    def generate_qr_code
      qr_code = RQRCode::QRCode.new(provisioning_uri)
      qr_code.as_png(
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: "black",
        file: nil,
        fill: "white",
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 200
      ).to_data_url
    end

    def ensure_can_disable
      unless @user.otp_required_for_sign_in?
        redirect_to settings_path, alert: "Two-factor authentication is not enabled."
      end

      if Boilermaker.config.require_two_factor_authentication?
        redirect_to settings_path, alert: "Two-factor authentication is required and cannot be disabled."
      end
    end
end
