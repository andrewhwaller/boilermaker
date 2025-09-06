# frozen_string_literal: true

# RecoveryCodeItem - A shared component for displaying recovery codes
# Handles both used and unused states with appropriate styling
class Components::RecoveryCodeItem < Components::Base
  def initialize(code:, used: false)
    @code = code
    @used = used
  end

  def view_template
    li(class: "font-mono text-sm") do
      if @used
        del(class: "opacity-60") { @code }
      else
        span(class: "text-base-content") { @code }
      end
    end
  end
end
