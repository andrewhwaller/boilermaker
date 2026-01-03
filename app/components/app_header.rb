# frozen_string_literal: true

class Components::AppHeader < Components::Base
  NavItem = Data.define(:label, :href, :active)

  def initialize(logo_text:, nav_items: [], user_email: nil, **attributes)
    @logo_text = logo_text
    @nav_items = nav_items.map { |item| item.is_a?(NavItem) ? item : NavItem.new(**item) }
    @user_email = user_email
    @attributes = attributes
  end

  def view_template
    header(class: header_classes, **filtered_attributes) do
      logo_section
      nav_section if @nav_items.any?
      user_section if @user_email
    end
  end

  private

  def header_classes
    css_classes(
      "border-b-2 border-border-default bg-surface",
      "px-6 py-3",
      "flex justify-between items-center"
    )
  end

  def logo_section
    div(class: "flex items-center gap-3") do
      span(class: "font-bold text-sm tracking-widest text-body") { @logo_text }
    end
  end

  def nav_section
    nav(class: "flex gap-6") do
      @nav_items.each { |item| nav_link(item) }
    end
  end

  def nav_link(item)
    a(
      href: item.href,
      class: nav_link_classes(item.active)
    ) { item.label }
  end

  def nav_link_classes(active)
    base = "text-xs tracking-wide no-underline transition-colors"
    active ? "#{base} text-body" : "#{base} text-muted hover:text-body"
  end

  def user_section
    span(class: "text-xs text-muted") { @user_email }
  end
end
