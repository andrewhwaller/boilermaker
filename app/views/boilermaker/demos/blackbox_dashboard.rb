# frozen_string_literal: true

module Views
  module Boilermaker
    module Demos
      # Blackbox theme demo page - comprehensive component showcase
      class BlackboxDashboard < Base
        def view_template
          render Views::Boilermaker::Layouts::BlackboxDashboard.new(
            title: "Dashboard",
            nav_items: [
              { label: "dashboard", href: blackbox_demos_path, active: true },
              { label: "search", href: "#", active: false },
              { label: "settings", href: "#", active: false }
            ]
          ) {
            render_workspace
            render_summary
            render_alerts
            render_data_table
            render_form_elements
            render_buttons
            render_badges
            render_text_content
          }
        end

        private

        def render_workspace
          section(class: "mb-4") {
            div(class: "ui-section-header") {
              div(class: "ui-section-title") { "Workspace" }
              a(href: "#", class: "ui-section-action") { "refresh" }
            }

            div(class: "bb-panel bb-dense") {
              # Filters / command row
              div(class: "bb-panel-header p-2") {
                div(class: "flex flex-wrap items-center gap-2 text-xs") {
                  span(class: "demo-label") { "QUERY" }
                  input(type: "text", value: "status:active updated:<30d", class: "ui-input w-[28ch]")

                  span(class: "demo-label") { "STATUS" }
                  select(class: "ui-select w-[16ch]") {
                    option { "Any" }
                    option(selected: true) { "Active" }
                    option { "Pending" }
                    option { "Review" }
                    option { "Archived" }
                  }

                  span(class: "demo-label") { "SORT" }
                  select(class: "ui-select w-[18ch]") {
                    option(selected: true) { "Updated desc" }
                    option { "Updated asc" }
                    option { "ID asc" }
                  }

                  span(class: "bb-divider") { "|" }
                  a(href: "#") { "export" }
                  a(href: "#") { "new" }
                }
              }

              # List + inspector
              div(class: "grid grid-cols-1 md:grid-cols-[1fr_20rem]") {
                div(class: "border-b md:border-b-0 md:border-r border-border-default") {
                  table(class: "ui-table text-xs") {
                    thead {
                      tr {
                        th(class: "w-[2ch]") { "" }
                        th { "ID" }
                        th { "Title" }
                        th { "Status" }
                        th(class: "text-right") { "Updated" }
                      }
                    }
                    tbody {
                      sample_patents.take(8).each_with_index do |patent, idx|
                        status = %w[Active Pending Review Archived][idx % 4]
                        selected = idx == 0
                        tr(class: selected ? "bb-row is-selected" : "bb-row") {
                          td(class: "text-muted") { selected ? ">" : "" }
                          td { patent.id }
                          td { patent.title }
                          td { status }
                          td(class: "text-right") { patent.date }
                        }
                      end
                    }
                  }

                  div(class: "flex flex-wrap justify-between gap-x-3 gap-y-1 p-2 text-xs text-muted border-t border-border-default") {
                    span { "8 items" }
                    span { "selected: 1" }
                    span { "page 1/12" }
                  }
                }

                div(class: "p-2") {
                  div(class: "text-xs font-semibold mb-2") { "Inspector" }

                  div(class: "grid grid-cols-[10ch_1fr] gap-x-3 gap-y-1 text-xs") {
                    span(class: "text-muted") { "ID" }
                    span { sample_patents.first.id }

                    span(class: "text-muted") { "STATUS" }
                    span(class: "bb-chip") { "ACTIVE" }

                    span(class: "text-muted") { "OWNER" }
                    span { "ops@company.com" }

                    span(class: "text-muted") { "UPDATED" }
                    span { sample_patents.first.date }

                    span(class: "text-muted") { "TAGS" }
                    span { "triage, watchlist" }
                  }

                  div(class: "mt-3 pt-2 border-t border-border-light") {
                    div(class: "text-xs text-muted mb-1") { "ACTIONS" }
                    div(class: "flex flex-wrap gap-x-3 gap-y-1 text-xs") {
                      a(href: "#") { "open" }
                      a(href: "#") { "assign" }
                      a(href: "#") { "archive" }
                    }
                  }
                }
              }
            }
          }
        end

        def render_summary
          section(class: "mb-4") {
            h2(class: "text-sm font-semibold mb-1") { "Summary" }
            div(class: "text-sm") {
              sample_stats.each do |stat|
                div(class: "flex justify-between py-0.5 border-b border-border-light") {
                  span { stat.label }
                  span(class: "font-semibold") { stat.value }
                }
              end
            }
          }
        end

        def render_alerts
          section(class: "mb-4") {
            h2(class: "text-sm font-semibold mb-1") { "Notifications" }
            div(class: "space-y-1 text-sm") {
              div(class: "ui-alert ui-alert-destructive p-2") {
                plain "Error: Connection to database failed. Retrying in 30s."
              }
              div(class: "ui-alert ui-alert-warning p-2") {
                plain "Warning: API rate limit at 80% capacity."
              }
              div(class: "ui-alert ui-alert-success p-2") {
                plain "Success: 47 new records imported."
              }
              div(class: "ui-alert p-2") {
                plain "Info: System maintenance scheduled for Sunday 02:00 UTC."
              }
            }
          }
        end

        def render_data_table
          section(class: "mb-4") {
            h2(class: "text-sm font-semibold mb-1") { "Recent Items" }
            table(class: "ui-table text-sm") {
              thead {
                tr {
                  th { "ID" }
                  th { "Title" }
                  th { "Status" }
                  th(class: "text-right") { "Date" }
                }
              }
              tbody {
                sample_patents.take(5).each_with_index do |patent, idx|
                  status = %w[Active Pending Review Archived][idx % 4]
                  tr {
                    td { patent.id }
                    td { patent.title }
                    td { status }
                    td(class: "text-right") { patent.date }
                  }
                end
              }
            }
          }
        end

        def render_form_elements
          section(class: "mb-4") {
            h2(class: "text-sm font-semibold mb-1") { "Form Elements" }
            div(class: "space-y-2 text-sm") {
              # Text input
              div(class: "flex gap-2") {
                input(type: "text", placeholder: "Text input", class: "ui-input flex-1")
                button(type: "button", class: "ui-button ui-button-primary") { "Submit" }
              }

              # Select
              div {
                select(class: "ui-select") {
                  option { "Select an option" }
                  option { "Option 1" }
                  option { "Option 2" }
                  option { "Option 3" }
                }
              }

              # Textarea
              div {
                textarea(class: "ui-textarea", rows: 2, placeholder: "Textarea for longer input...")
              }

              # Checkboxes and radios
              div(class: "flex gap-4") {
                label(class: "flex items-center gap-1") {
                  input(type: "checkbox", class: "ui-checkbox", checked: true)
                  span { "Checkbox 1" }
                }
                label(class: "flex items-center gap-1") {
                  input(type: "checkbox", class: "ui-checkbox")
                  span { "Checkbox 2" }
                }
              }

              div(class: "flex gap-4") {
                label(class: "flex items-center gap-1") {
                  input(type: "radio", name: "demo-radio", class: "ui-radio", checked: true)
                  span { "Radio A" }
                }
                label(class: "flex items-center gap-1") {
                  input(type: "radio", name: "demo-radio", class: "ui-radio")
                  span { "Radio B" }
                }
              }
            }
          }
        end

        def render_buttons
          section(class: "mb-4") {
            h2(class: "text-sm font-semibold mb-1") { "Buttons" }
            div(class: "flex flex-wrap gap-2 text-sm") {
              button(class: "ui-button ui-button-primary") { "Primary" }
              button(class: "ui-button ui-button-secondary") { "Secondary" }
              button(class: "ui-button ui-button-outline") { "Outline" }
              button(class: "ui-button ui-button-ghost") { "Ghost" }
              a(href: "#", class: "ui-button ui-button-link") { "Link" }
            }
            div(class: "flex flex-wrap gap-2 text-sm mt-2") {
              button(class: "ui-button ui-button-error") { "Error" }
              button(class: "ui-button ui-button-success") { "Success" }
              button(class: "ui-button ui-button-warning") { "Warning" }
              button(class: "ui-button", disabled: true) { "Disabled" }
            }
          }
        end

        def render_badges
          section(class: "mb-4") {
            h2(class: "text-sm font-semibold mb-1") { "Badges" }
            div(class: "flex flex-wrap gap-2") {
              span(class: "ui-badge ui-badge-primary") { "Primary" }
              span(class: "ui-badge ui-badge-secondary") { "Secondary" }
              span(class: "ui-badge ui-badge-success") { "Success" }
              span(class: "ui-badge ui-badge-warning") { "Warning" }
              span(class: "ui-badge ui-badge-error") { "Error" }
              span(class: "ui-badge ui-badge-outline") { "Outline" }
            }
          }
        end

        def render_text_content
          section(class: "mb-4") {
            h2(class: "text-sm font-semibold mb-1") { "Typography" }
            div(class: "space-y-1 text-sm") {
              p {
                plain "Regular paragraph text. "
                a(href: "#") { "This is a link" }
                plain " within text content. "
                strong { "Bold text" }
                plain " and "
                em { "italic text" }
                plain " are also supported."
              }
              p(class: "text-muted") {
                plain "Muted text for secondary information or metadata."
              }
              div(class: "bg-surface-alt p-2 text-xs") {
                code { "Monospace code block for displaying technical output or logs." }
              }
            }
          }
        end
      end
    end
  end
end
