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
    li do
      classes = base_classes
      classes += " #{@options[:class]}" if @options[:class]

      if @path
        if @method == :delete
          link_to(@text, @path, class: classes, data: { turbo_method: :delete }, **@options.except(:class, :data))
        else
          link_to(@text, @path, class: classes, **@options.except(:class))
        end
      else
        a(href: "#", class: classes, **@options.except(:class)) { @text }
      end
    end
  end

  private

  def base_classes
    "justify-start text-sm"
  end
end
