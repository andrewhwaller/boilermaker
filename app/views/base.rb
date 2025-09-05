# frozen_string_literal: true

class Views::Base < Components::Base
  # The `Views::Base` is an abstract class for all your views.

  # By default, it inherits from `Components::Base`, but you
  # can change that to `Phlex::HTML` if you want to keep views and
  # components independent.

  # Include any helpers you want to be available across all views
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::CurrentPage
  include Phlex::Rails::Helpers::Pluralize
  include ApplicationHelper

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end

  protected

  # Helper method to render page with title
  def page_with_title(title = nil, &block)
    set_title(title) if title.present?
    yield_content_or(&block)
  end

  # Helper method to render a section with consistent styling
  def section(title: nil, **attrs, &block)
    section_class = "space-y-6"
    section_class = [ section_class, attrs.delete(:class) ].compact.join(" ")

    super(**attrs.merge(class: section_class)) do
      if title.present?
        h2(class: "text-xl font-semibold text-base-content mb-4") { title }
      end
      yield_content_or(&block)
    end
  end

  # Helper method to render a card container
  def card(**attrs, &block)
    card_class = "bg-base-200 border border-base-300 rounded-lg p-6 shadow-sm"
    card_class = [ card_class, attrs.delete(:class) ].compact.join(" ")

    div(**attrs.merge(class: card_class)) do
      yield_content_or(&block)
    end
  end

  # Helper method to render form errors
  def form_errors(model)
    return unless model&.errors&.any?

    div(class: "alert alert-error mb-6") do
      div do
        strong { "#{pluralize(model.errors.count, "error")} prohibited this #{model.class.name.downcase} from being saved:" }
        ul(class: "list-disc list-inside mt-2") do
          model.errors.full_messages.each do |message|
            li(class: "text-sm") { message }
          end
        end
      end
    end
  end

  # Helper method to render a centered container
  def centered_container(**attrs, &block)
    container_class = "max-w-md mx-auto"
    container_class = [ container_class, attrs.delete(:class) ].compact.join(" ")

    div(**attrs.merge(class: container_class)) do
      yield_content_or(&block)
    end
  end

  # Helper method to render a wide container
  def wide_container(**attrs, &block)
    container_class = "max-w-4xl mx-auto"
    container_class = [ container_class, attrs.delete(:class) ].compact.join(" ")

    div(**attrs.merge(class: container_class)) do
      yield_content_or(&block)
    end
  end

  # Helper method to set page title
  def set_title(title)
    content_for(:title, title)
  end

  # Helper method to get page title with fallback
  def page_title
    content_for?(:title) ? content_for(:title) : "Boilermaker"
  end

  protected

  # Helper to handle both content_for and direct block content
  def yield_content_or(&block)
    if block_given?
      yield
    elsif content_for?(:content)
      content_for(:content)
    end
  end
end
