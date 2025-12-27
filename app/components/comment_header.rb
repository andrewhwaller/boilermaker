# frozen_string_literal: true

# Section header with // comment prefix (terminal-style)
# Renders: // SECTION_TITLE with dashed border
class Components::CommentHeader < Components::Base
  def initialize(title:, **attributes)
    @title = title
    @attributes = attributes
  end

  def view_template
    div(
      **@attributes,
      class: css_classes(
        "text-[11px] uppercase tracking-[0.1em] text-muted",
        "border-b border-dashed border-border-light",
        "pb-1 mb-2"
      )
    ) {
      plain "// #{@title}"
    }
  end
end
