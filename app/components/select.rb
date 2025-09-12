# frozen_string_literal: true

class Components::Select < Components::Base
  SIZES = {
    xs: "select-xs",
    sm: "select-sm",
    md: nil,
    lg: "select-lg"
  }.freeze

  def initialize(name: nil, options: [], selected: nil, prompt: nil, required: false, error: nil, id: nil, size: :md, **attributes)
    @name = name
    @options = options
    @selected = selected
    @prompt = prompt
    @required = required
    @error = error
    @id = id
    @size = size
    @attributes = attributes
  end

  def view_template
    div(class: "form-control w-full") do
      select(
        name: @name,
        id: @id || generate_id_from_name(@name),
        class: select_classes,
        required: (@required ? "required" : nil),
        **@attributes.except(:class)
      ) do
        render_prompt if @prompt
        render_options
      end
      render_error_message if @error
    end
  end

  private

  def select_classes
    base_classes = [ "select", "select-bordered", "w-full", SIZES[@size] ]
    base_classes << "select-error" if @error
    custom_classes = @attributes[:class]

    [ base_classes, custom_classes ].flatten.compact.join(" ")
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

  def render_error_message
    div(class: "label-text-alt text-error mt-1") { @error }
  end
end
