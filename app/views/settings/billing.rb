# frozen_string_literal: true

module Views
  module Settings
    class Billing < Views::Base
      include Phlex::Rails::Helpers::LinkTo
      include Phlex::Rails::Helpers::ButtonTo

      def initialize(billable:)
        @billable = billable
      end

      def view_template
        page_with_title("Billing") do
          div(class: "max-w-xl space-y-6") do
            render_subscription_status
            render_billing_actions
            render_invoices if @billable.payment_processor&.charges&.any?
          end
        end
      end

      private

      def render_subscription_status
        render Components::Card.new(title: "Current Plan", header_color: :primary) do
          subscription = @billable.payment_processor&.subscription

          if subscription&.active?
            div(class: "space-y-2") do
              div(class: "flex items-center gap-2") do
                span(class: "font-semibold") { subscription.processor_plan.titleize }
                render Components::Badge.new(variant: :success, size: :sm) { "Active" }
              end
              p(class: "text-sm text-base-content/70") do
                "Your subscription renews on #{subscription.current_period_end&.strftime('%B %d, %Y')}"
              end
            end
          else
            div(class: "space-y-2") do
              p(class: "text-base-content/70") { "You don't have an active subscription." }
              link_to "View Plans", pricing_path, class: "ui-button ui-button-primary"
            end
          end
        end
      end

      def render_billing_actions
        return unless @billable.payment_processor&.subscription&.active?

        render Components::Card.new(title: "Manage Subscription", header_color: :primary) do
          div(class: "space-y-4") do
            p(class: "text-sm text-base-content/70") do
              "Update your payment method, view invoices, or cancel your subscription."
            end
            button_to "Manage Billing", billing_portal_path,
                      method: :post,
                      class: "ui-button ui-button-outline"
          end
        end
      end

      def render_invoices
        render Components::Card.new(title: "Recent Invoices", header_color: :primary) do
          div(class: "space-y-2") do
            @billable.payment_processor.charges.order(created_at: :desc).limit(5).each do |charge|
              div(class: "flex justify-between items-center py-2 border-b border-base-300 last:border-0") do
                div do
                  span(class: "font-medium") { charge.created_at.strftime("%B %d, %Y") }
                  span(class: "text-sm text-base-content/70 ml-2") { number_to_currency(charge.amount / 100.0) }
                end
                if charge.receipt_url
                  link_to "Receipt", charge.receipt_url, target: "_blank", class: "text-sm ui-link"
                end
              end
            end
          end
        end
      end
    end
  end
end
