# frozen_string_literal: true

module FormErrorHandling
  def render_error_message
    return unless @error
    div(class: "label-text-alt text-error mt-1") { @error }
  end

  def error_classes_for(base_class)
    @error ? "ui-#{base_class}-error" : nil
  end
end
