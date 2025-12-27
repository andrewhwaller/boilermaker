# frozen_string_literal: true

# Keyboard shortcut badge (brutalist-style)
# Renders: <kbd>key</kbd> with styled appearance
class Components::KbdHint < Components::Base
  def initialize(key:, **attributes)
    @key = key
    @attributes = attributes
  end

  def view_template
    kbd(
      **@attributes,
      class: css_classes(
        "font-mono text-[10px]",
        "bg-surface-alt border border-border-default",
        "rounded px-1"
      )
    ) {
      @key
    }
  end
end
