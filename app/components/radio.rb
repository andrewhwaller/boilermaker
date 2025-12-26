# frozen_string_literal: true

class Components::Radio < Components::Base
  include FormErrorHandling
  def initialize(name: nil, options: [], selected: nil, required: false, error: nil, **attributes)
    @name = name
    @options = options
    @selected = selected
    @required = required
    @error = error
    @attributes = attributes
  end

  def view_template
    div(class: "form-control") do
      @options.each_with_index do |(text, value), index|
        render_radio_option(text, value, index)
      end
      render_error_message if @error
    end
  end

  private

  def render_radio_option(text, value, index)
    label(class: "flex items-center gap-2") do # Use flex for alignment
      input(**radio_attributes(value, index))
      span(class: label_classes) { text }
    end
  end

  private

  def radio_attributes(value, index)
    attrs = {
      type: "radio",
      name: @name,
      id: "#{generate_id_from_name(@name)}_#{index}",
      value: value,
      checked: value.to_s == @selected.to_s,
      required: (@required && index == 0) ? "required" : nil
    }

    # Merge classes properly
    all_classes = radio_classes
    if @attributes[:class]
      all_classes += Array(@attributes[:class])
    end
    attrs[:class] = all_classes

    # Add other attributes
    attrs.merge!(@attributes.except(:class))
    attrs.compact
  end

  def label_classes
    css_classes("label-text", @error ? "text-destructive" : nil)
  end

  def radio_classes
    css_classes("radio", error_classes_for("radio"))
  end
end
