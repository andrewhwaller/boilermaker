# Base view component class for all page views
# Provides common functionality and integration with Rails helpers
class BaseView < Phlex::HTML
  # Allow views to specify their layout
  class_attribute :layout_class, default: -> { Layouts::ApplicationLayout }

  def initialize(**attrs)
    @attrs = attrs
  end

  # Main view template - to be overridden by subclasses
  def view_template
    raise NotImplementedError, "Subclasses must implement #view_template"
  end

  private

  attr_reader :attrs

  # Helper method to merge CSS classes
  def merge_classes(*classes)
    classes.compact.join(" ")
  end

  # Helper method to extract specific attributes
  def extract_attrs(*keys)
    attrs.slice(*keys)
  end

  # Helper method to get remaining attributes after extraction
  def remaining_attrs(*excluded_keys)
    attrs.except(*excluded_keys)
  end

  # Helper method to conditionally add classes
  def conditional_classes(conditions = {})
    conditions.map { |condition, classes| classes if condition }.compact.join(" ")
  end

  # Render a UI component
  def ui_component(component_class, **component_attrs, &block)
    render component_class.new(**component_attrs), &block
  end

  # Convenience methods for common UI components
  def ui_button(**attrs, &block)
    ui_component(Ui::ButtonComponent, **attrs, &block)
  end

  def ui_input(**attrs)
    ui_component(Ui::InputComponent, **attrs)
  end

  def ui_label(**attrs, &block)
    ui_component(Ui::LabelComponent, **attrs, &block)
  end
end
