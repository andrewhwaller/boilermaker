# frozen_string_literal: true

module Settings
  class BillingsController < ApplicationController
    include PaymentsFeature

    before_action :require_authentication

    def show
      render Views::Settings::Billing.new(billable: Current.user)
    end
  end
end
