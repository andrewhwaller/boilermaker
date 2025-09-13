

module Boilermaker
  class SettingsController < Boilermaker::ApplicationController
    before_action :add_engine_view_path
    before_action :load_settings, only: [ :show, :edit ]
    skip_before_action :verify_authenticity_token if Rails.env.development?

    def show
      render "boilermaker/settings/show"
    end

    def edit
      render "boilermaker/settings/edit"
    end

    def update
      return head :forbidden unless Rails.env.development?

      Boilermaker::Config.update_from_params!(settings_params.to_h)
      redirect_to boilermaker.settings_path, notice: "Settings updated!"
    rescue => error
      render_invalid(settings_params.to_h.deep_stringify_keys, error)
    end

    private

    def add_engine_view_path
      prepend_view_path File.expand_path("../../views", __dir__)
    end

    def load_settings
      @settings = Boilermaker::Config.data || {}
      @features = @settings.dig("features") || {}
    end


    def settings_params
      params.require(:settings).permit(
        app: [ :name, :version, :support_email, :description ],
        ui: { theme: [ :light, :dark ] },
        features: [ :user_registration, :password_reset, :two_factor_authentication, :multi_tenant, :personal_accounts ]
      )
    end



    def render_invalid(posted, error)
      @settings = (Boilermaker::Config.data || {}).merge(posted)
      @features = @settings.dig("features") || {}
      flash.now[:alert] = "Invalid configuration: #{error.message}"
      render "boilermaker/settings/edit", status: :unprocessable_entity
    end
  end
end
