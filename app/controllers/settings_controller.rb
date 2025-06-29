# frozen_string_literal: true

class SettingsController < ApplicationController
  skip_before_action :ensure_verified

  def show
    render Views::Settings::Show.new
  end
end
