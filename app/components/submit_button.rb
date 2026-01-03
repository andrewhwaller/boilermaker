# frozen_string_literal: true

# SubmitButton - A specialized button component for form submissions
# Provides consistent styling and behavior for submit buttons
class Components::SubmitButton < Components::Base
  def initialize(text = "Submit", variant: :primary, **button_attrs)
    @text = text
    @variant = variant
    @button_attrs = button_attrs
  end

  def view_template(&block)
    render Components::Button.new(type: :submit, variant: @variant, **@button_attrs) do
      if block_given?
        yield
      else
        @text
      end
    end
  end
end
