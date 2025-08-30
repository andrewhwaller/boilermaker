# frozen_string_literal: true

class Components::DropdownMenuSeparator < Components::Base
  def view_template
    div(class: "h-px bg-border-subtle my-1")
  end
end