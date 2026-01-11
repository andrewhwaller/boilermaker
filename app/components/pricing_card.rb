# frozen_string_literal: true

module Components
  class PricingCard < Components::Base
    include Phlex::Rails::Helpers::ButtonTo

    def initialize(plan_id:, name:, price:, features:, current: false, popular: false)
      @plan_id = plan_id
      @name = name
      @price = price
      @features = features
      @current = current
      @popular = popular
    end

    def view_template
      div(class: card_classes) do
        render_popular_badge if @popular
        render_header
        render_features
        render_action
      end
    end

    private

    def card_classes
      base = "relative p-6 rounded-lg border"
      if @popular
        "#{base} border-primary bg-primary/5"
      else
        "#{base} border-base-300 bg-base-100"
      end
    end

    def render_popular_badge
      div(class: "absolute -top-3 left-1/2 -translate-x-1/2") do
        render Components::Badge.new(variant: :primary, size: :sm) { "Most Popular" }
      end
    end

    def render_header
      div(class: "text-center mb-6") do
        h3(class: "text-xl font-bold mb-2") { @name }
        div(class: "text-3xl font-bold") { @price }
      end
    end

    def render_features
      ul(class: "space-y-3 mb-6") do
        @features.each do |feature|
          li(class: "flex items-center gap-2") do
            svg(class: "w-5 h-5 text-success", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
              s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M5 13l4 4L19 7")
            end
            span { feature }
          end
        end
      end
    end

    def render_action
      if @current
        div(class: "text-center") do
          render Components::Badge.new(variant: :success, size: :lg) { "Current Plan" }
        end
      else
        button_to "Select Plan", checkout_path(plan: @plan_id),
                  method: :post,
                  class: button_classes
      end
    end

    def button_classes
      if @popular
        "w-full ui-button ui-button-primary"
      else
        "w-full ui-button ui-button-outline"
      end
    end
  end
end
