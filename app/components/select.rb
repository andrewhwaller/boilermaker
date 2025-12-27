# frozen_string_literal: true

class Components::Select < Components::Base
  include FormErrorHandling
  def initialize(name: nil, options: [], selected: nil, prompt: nil, required: false, error: nil, id: nil, **attributes)
    @name = name
    @options = options
    @selected = selected
    @prompt = prompt
    @required = required
    @error = error
    @id = id
    @attributes = attributes
  end

  def view_template
    div(class: "form-control") do
      select(**select_attributes) do
        render_prompt if @prompt
        render_options
      end
      render_error_message if @error
    end
  end

  private

  def select_attributes
    attrs = {
      name: @name,
      id: @id || generate_id_from_name(@name),
      required: (@required ? "required" : nil)
    }

    # Merge classes properly
    all_classes = select_classes
    if @attributes[:class]
      all_classes += Array(@attributes[:class])
    end
    attrs[:class] = all_classes

    # Add other attributes
    attrs.merge!(@attributes.except(:class))
    attrs.compact
  end

  private

  def select_classes
    css_classes("ui-select", error_classes_for("select"))
  end

  def render_prompt
    option(value: "", disabled: true, selected: @selected.blank?) { @prompt }
  end

  def render_options
    case @options
    when Hash
      @options.each { |text, value| render_option(text, value) }
    when Array
      if @options.first.is_a?(Array)
        @options.each { |text, value| render_option(text, value) }
      else
        @options.each { |option| render_option(option, option) }
      end
    end
  end

  def render_option(text, value)
    option(value: value, selected: value.to_s == @selected.to_s) { text }
  end
end
