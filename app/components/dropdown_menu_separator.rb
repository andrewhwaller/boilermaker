# frozen_string_literal: true

class Components::DropdownMenuSeparator < Components::Base
  def view_template
    div(class: "h-px bg-gray-200 dark:bg-gray-600 my-1")
  end
end