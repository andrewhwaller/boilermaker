# frozen_string_literal: true

class Components::DropdownMenuItem < Components::Base
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(text, path = nil, method: :get, **options)
    @text = text
    @path = path
    @method = method
    @options = options
  end

  def view_template
    classes = base_classes
    classes += " #{@options[:class]}" if @options[:class]

    if @path
      if @method == :delete
        button_to(@text, @path, method: @method, class: classes, **@options.except(:class))
      else
        link_to(@text, @path, class: classes, **@options.except(:class))
      end
    else
      div(class: classes, **@options.except(:class)) { @text }
    end
  end

  private

  def base_classes
    "block w-full px-4 py-2 text-sm text-left text-gray-900 dark:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-700 border-0 bg-transparent"
  end
end