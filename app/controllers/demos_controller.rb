# frozen_string_literal: true

class DemosController < ApplicationController
  skip_before_action :authenticate, only: %i[terminal blueprint brutalist amber paper industrial]
  skip_before_action :set_current_account, only: %i[terminal blueprint brutalist amber paper industrial]
  skip_before_action :enforce_two_factor_setup, only: %i[terminal blueprint brutalist amber paper industrial]
  skip_before_action :ensure_verified, only: %i[terminal blueprint brutalist amber paper industrial]

  layout false

  def terminal
    render Views::Boilermaker::Demos::TerminalDashboard.new
  end

  def blueprint
    render Views::Boilermaker::Demos::BlueprintDashboard.new
  end

  def brutalist
    render Views::Boilermaker::Demos::BrutalistDashboard.new
  end

  def amber
    render Views::Boilermaker::Demos::AmberDashboard.new
  end

  def paper
    render Views::Boilermaker::Demos::PaperDashboard.new
  end

  def industrial
    render Views::Boilermaker::Demos::IndustrialDashboard.new
  end
end
