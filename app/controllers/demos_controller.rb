# frozen_string_literal: true

class DemosController < ApplicationController
  skip_before_action :authenticate, only: %i[terminal blueprint brutalist dos paper]
  skip_before_action :set_current_account, only: %i[terminal blueprint brutalist dos paper]
  skip_before_action :enforce_two_factor_setup, only: %i[terminal blueprint brutalist dos paper]
  skip_before_action :ensure_verified, only: %i[terminal blueprint brutalist dos paper]

  layout false

  def terminal
    render Views::Demos::TerminalDashboard.new
  end

  def blueprint
    render Views::Demos::BlueprintDashboard.new
  end

  def brutalist
    render Views::Demos::BrutalistDashboard.new
  end

  def dos
    render Views::Demos::DosDashboard.new
  end

  def paper
    render Views::Demos::PaperDashboard.new
  end
end
