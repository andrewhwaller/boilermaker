# frozen_string_literal: true

class PaymentsController < ApplicationController
  include PaymentsFeature

  before_action :require_authentication, except: [ :pricing ]
  before_action :set_billable, except: [ :pricing ]

  # GET /pricing
  def pricing
    render Views::Payments::Pricing.new(
      current_plan: @billable&.payment_processor&.subscription&.processor_plan
    )
  end

  # POST /payments/checkout/:plan
  def checkout
    plan = params[:plan]

    unless valid_plan?(plan)
      redirect_to pricing_path, alert: "Invalid plan selected"
      return
    end

    # Create or get Stripe customer
    @billable.set_payment_processor(:stripe)

    checkout_session = @billable.payment_processor.checkout(
      mode: "subscription",
      line_items: plan_line_items(plan),
      success_url: payment_success_url(session_id: "{CHECKOUT_SESSION_ID}"),
      cancel_url: payment_cancel_url
    )

    redirect_to checkout_session.url, allow_other_host: true
  end

  # GET /payments/success
  def success
    redirect_to settings_billing_path, notice: "Thank you for subscribing!"
  end

  # GET /payments/cancel
  def cancel
    redirect_to pricing_path, notice: "Checkout cancelled"
  end

  # POST /payments/portal
  def portal
    @billable.set_payment_processor(:stripe)

    portal_session = @billable.payment_processor.billing_portal(
      return_url: settings_billing_url
    )

    redirect_to portal_session.url, allow_other_host: true
  end

  private

  def set_billable
    @billable = Current.user
  end

  def valid_plan?(plan)
    return false unless defined?(Pay::PLANS)
    Pay::PLANS.key?(plan)
  end

  def plan_line_items(plan)
    price_id = Pay::PLANS.dig(plan, :price_id)
    raise "Price ID not found for plan: #{plan}" unless price_id

    [ { price: price_id, quantity: 1 } ]
  end
end
