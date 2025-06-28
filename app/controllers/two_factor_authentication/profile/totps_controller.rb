class TwoFactorAuthentication::Profile::TotpsController < ApplicationController
  before_action :set_user
  before_action :set_totp, only: %i[ new create ]

  def new
    qr_code = RQRCode::QRCode.new(provisioning_uri)
    @qr_code_data_url = qr_code.as_png(
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
    render Views::TwoFactorAuthentication::Profile::Totps::New.new(totp: @totp, qr_code: @qr_code_data_url)
  end

  def create
    if @totp.verify(params[:code], drift_behind: 15)
      @user.update! otp_required_for_sign_in: true
      redirect_to two_factor_authentication_profile_recovery_codes_path
    else
      redirect_to new_two_factor_authentication_profile_totp_path, alert: "That code didn't work. Please try again"
    end
  end

  def update
    @user.update! otp_secret: ROTP::Base32.random
    redirect_to new_two_factor_authentication_profile_totp_path
  end

  private
    def set_user
      @user = Current.user
    end

    def set_totp
      @totp = ROTP::TOTP.new(@user.otp_secret, issuer: "Boilermaker")
    end

    def provisioning_uri
      @totp.provisioning_uri @user.email
    end
end
