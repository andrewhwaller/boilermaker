

module Boilermaker
  class SettingsController < Boilermaker::ApplicationController
    before_action :add_engine_view_path
    before_action :load_settings, only: [ :edit ]
    skip_before_action :verify_authenticity_token if Rails.env.development?

    def edit
      render "boilermaker/settings/edit"
    end

    def update
      return head :forbidden unless Rails.env.development?

      Boilermaker::Config.update_from_params!(settings_params.to_h)
      redirect_to boilermaker.edit_settings_path, notice: "Settings updated!"
    rescue => error
      render_invalid(settings_params.to_h.deep_stringify_keys, error)
    end

    private

    def add_engine_view_path
      prepend_view_path File.expand_path("../../views", __dir__)
    end

    def load_settings
      Boilermaker::Config.reload! unless Boilermaker::Config.data
      @settings = Boilermaker::Config.data || {}
      @features = @settings.dig("features") || {}
    end


    def settings_params
      params.require(:settings).permit(
        app: [ :name, :version, :support_email, :description ],
        ui: {
          theme: [ :name ],
          navigation: [ :layout_mode ],
          typography: [ :font, :uppercase, :size ]
        },
        features: [ :user_registration, :personal_accounts ]
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
