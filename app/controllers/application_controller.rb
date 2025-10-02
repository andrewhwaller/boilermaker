# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers

  before_action :assign_theme_from_cookie
  before_action :set_current_request_details
  before_action :authenticate
  before_action :set_current_account
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

  # Server-driven theme selection for first paint
  def assign_theme_from_cookie
    name = cookies[:theme_name].to_s.strip
    Current.theme_name = resolve_theme_name(name)
  rescue
    Current.theme_name = resolve_theme_name(nil)
  end

  def resolve_theme_name(name)
    # Accept configured names first
    return name if [ Boilermaker::Config.theme_light_name, Boilermaker::Config.theme_dark_name ].include?(name)
    # Accept custom themes
    return name if Boilermaker::Themes::ALL.include?(name)
    # Accept built-in DaisyUI themes
    if defined?(Boilermaker::Themes) && Boilermaker::Themes::BUILTINS.include?(name)
      return name
    end
    # Fallback to configured light theme
    Boilermaker::Config.theme_light_name
  end
end
