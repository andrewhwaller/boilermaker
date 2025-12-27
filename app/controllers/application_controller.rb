# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers

  before_action :assign_theme_from_cookie
  before_action :set_current_request_details
  before_action :authenticate
  before_action :set_current_account
  before_action :enforce_two_factor_setup
  before_action :ensure_verified

  layout "application"

  private

    def authenticate
      if session_record = Session.find_by_id(cookies.signed[:session_token])
        Current.session = session_record
      else
        redirect_to sign_in_path
      end
    end

    def ensure_verified
      redirect_to edit_identity_email_path unless Current.user&.verified?
    end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end

    def set_current_account
      return unless Current.session
      Current.account = Current.session.account || Current.user.accounts.first!
    end

    def enforce_two_factor_setup
      return unless Current.user
      return unless Boilermaker.config.require_two_factor_authentication?
      return if Current.user.otp_required_for_sign_in?

      redirect_to new_two_factor_authentication_profile_totp_path,
                  alert: "You must set up two-factor authentication to continue"
    end

    # Server-driven theme/polarity selection for first paint
    def assign_theme_from_cookie
      # Theme is admin-controlled via config
      Current.theme_name = Boilermaker::Config.theme_name

      # Polarity is user-controlled via cookie
      polarity = cookies[:polarity].to_s.strip
      Current.polarity = resolve_polarity(polarity)
    rescue => e
      Rails.logger.warn "[theme] Error loading theme: #{e.message}"
      Current.theme_name = "paper"
      Current.polarity = "light"
    end

    def resolve_polarity(polarity)
      return polarity if Boilermaker::Themes.valid_polarity?(polarity)
      Boilermaker::Themes.default_polarity_for(Current.theme_name)
    end
end
