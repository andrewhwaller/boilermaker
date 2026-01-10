# frozen_string_literal: true

module Views
  module Payments
    class Pricing < Views::Base
      include Phlex::Rails::Helpers::LinkTo
      include Phlex::Rails::Helpers::ButtonTo

      def initialize(current_plan: nil)
        @current_plan = current_plan
      end

      def view_template
        page_with_title("Pricing") do
          div(class: "max-w-4xl mx-auto") do
            div(class: "text-center mb-8") do
              h1(class: "text-3xl font-bold mb-2") { "Choose Your Plan" }
              p(class: "text-base-content/70") { "Select the plan that best fits your needs" }
            end

            div(class: "grid md:grid-cols-3 gap-6") do
              render_plan_cards
            end
          end
        end
      end

      private

      def render_plan_cards
        plans.each do |plan_id, plan|
          render Components::PricingCard.new(
            plan_id: plan_id,
            name: plan[:name],
            price: plan[:price],
            features: plan[:features],
            current: @current_plan == plan_id,
            popular: plan[:popular]
          )
        end
      end

      def plans
        return Pay::PLANS if defined?(Pay::PLANS)

        # Default plans if Pay::PLANS not configured
        {
          "starter" => {
            name: "Starter",
            price: "$9/mo",
            features: [ "5 projects", "Basic support", "1GB storage" ],
            popular: false
          },
          "professional" => {
            name: "Professional",
            price: "$29/mo",
            features: [ "Unlimited projects", "Priority support", "10GB storage", "Advanced analytics" ],
            popular: true
          },
          "enterprise" => {
            name: "Enterprise",
            price: "$99/mo",
            features: [ "Everything in Pro", "Dedicated support", "Unlimited storage", "Custom integrations" ],
            popular: false
          }
        }
      end
    end
  end
end
