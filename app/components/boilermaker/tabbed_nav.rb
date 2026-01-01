# frozen_string_literal: true

# Tab-style navigation (blueprint-style)
# Each tab is a link that can be active or inactive
# Active tab has 3-sided border (no bottom) that overlaps the nav's bottom border
class Components::Boilermaker::TabbedNav < Components::Boilermaker::Base
  Tab = Data.define(:label, :href, :active) do
    def initialize(label:, href:, active: false) = super
  end

  def initialize(tabs:, **attributes)
    @tabs = tabs.map { |t| t.is_a?(Tab) ? t : Tab.new(**t) }
    @attributes = attributes
  end

  def view_template
    nav(**@attributes, class: css_classes("flex gap-0 border-b-2 border-accent mb-8")) {
      @tabs.each { |tab| render_tab(tab) }
    }
  end

  private

  def render_tab(tab)
    if tab.active
      a(
        href: tab.href,
        class: "px-5 py-2.5 text-[11px] uppercase tracking-[0.08em] no-underline " \
               "text-accent bg-surface -mb-[2px] " \
               "border-2 border-accent border-b-0"
      ) { tab.label }
    else
      a(
        href: tab.href,
        class: "px-5 py-2.5 text-[11px] uppercase tracking-[0.08em] no-underline " \
               "text-muted hover:text-accent -mb-[2px] " \
               "border-2 border-transparent border-b-0"
      ) { tab.label }
    end
  end
end
