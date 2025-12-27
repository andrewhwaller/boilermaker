# frozen_string_literal: true

class Components::AppFooter < Components::Base
  StatusItem = Data.define(:label, :online) do
    def initialize(label:, online: false)
      super
    end
  end

  def initialize(status_items: [], version_text: nil, **attributes)
    @status_items = status_items.map { |item| item.is_a?(StatusItem) ? item : StatusItem.new(**item) }
    @version_text = version_text
    @attributes = attributes
  end

  def view_template
    footer(class: footer_classes, **filtered_attributes) do
      status_section if @status_items.any?
      version_section if @version_text
    end
  end

  private

  def footer_classes
    css_classes(
      "border-t border-border-light bg-surface",
      "px-6 py-3 mt-12",
      "flex justify-between items-center",
      "text-[10px] text-muted"
    )
  end

  def status_section
    div(class: "flex gap-4") do
      @status_items.each { |item| status_item(item) }
    end
  end

  def status_item(item)
    span(class: "flex items-center gap-1.5") do
      if item.online
        span(class: "w-1.5 h-1.5 rounded-full bg-accent-alt")
      end
      plain item.label
    end
  end

  def version_section
    span { @version_text }
  end
end
