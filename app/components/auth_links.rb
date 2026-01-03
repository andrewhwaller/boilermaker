# frozen_string_literal: true

# AuthLinks - A shared component for authentication-related navigation links
# Provides consistent styling and spacing for auth form links
class Components::AuthLinks < Components::Base
  def initialize(links: [], separator: "|", center: true)
    @links = links
    @separator = separator
    @center = center
  end

  def view_template
    container_class = "mt-6 space-x-2"
    container_class += " text-center" if @center

    div(class: container_class) do
      @links.each_with_index do |link, index|
        # Add separator between links (but not before first link)
        if index > 0 && @separator.present?
          span(class: "text-muted") { @separator }
        end

        # Render the link
        render Components::Link.new(
          href: link[:path],
          text: link[:text],
          class: "link" # Apply the base link style
        )
      end
    end
  end
end
