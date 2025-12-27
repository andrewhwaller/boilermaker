# frozen_string_literal: true

class DemosController < ApplicationController
  skip_before_action :authenticate, only: %i[terminal blueprint brutalist amber paper industrial]
  skip_before_action :set_current_account, only: %i[terminal blueprint brutalist amber paper industrial]
  skip_before_action :enforce_two_factor_setup, only: %i[terminal blueprint brutalist amber paper industrial]
  skip_before_action :ensure_verified, only: %i[terminal blueprint brutalist amber paper industrial]

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

  def amber
    render Views::Demos::AmberDashboard.new
  end

  def paper
    render Views::Demos::PaperDashboard.new
  end

  def industrial
    render Views::Demos::IndustrialDashboard.new
  end
end
