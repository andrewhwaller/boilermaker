# frozen_string_literal: true

class Views::Home::Components < Views::Base
  def view_template
    div(class: "min-h-screen bg-base-100") do
      # Header with Navigation
      div(class: "sticky top-0 bg-base-200 border-b border-base-300 p-4 z-10") do
        div(class: "flex items-center justify-between max-w-6xl mx-auto") do
          h1(class: "text-2xl font-bold text-base-content") { "Phlex Component Showcase" }
          div(class: "flex items-center gap-4") do
            p(class: "text-sm text-base-content/70") { "Comprehensive component library documentation" }
            render Components::ThemeToggle.new
          end
        end

        # Component navigation
        div(class: "max-w-6xl mx-auto mt-4") do
          nav(class: "flex flex-wrap gap-2") do
            nav_link("Overview", "#overview")
            nav_link("Links", "#links")
            nav_link("Buttons", "#buttons")
            nav_link("Form Inputs", "#form-inputs")
            nav_link("Form Components", "#form-components")
            nav_link("Feedback", "#feedback")
            nav_link("Utility", "#utility")
            nav_link("Tables", "#tables")
            nav_link("Layout", "#layout")
            nav_link("Testing", "#testing")
            nav_link("Style Guide", "#style-guide")
          end
        end
      end

      # Main Content
      div(class: "max-w-6xl mx-auto p-8 space-y-16") do
        # Links Section
        section(id: "links") do
          h2(class: "text-2xl font-bold text-base-content mb-8 border-b border-base-300 pb-4") { "Link Components" }

          component_section("Link Variants", "All link variants with proper styling and hover effects") do
            div(class: "flex flex-wrap gap-4") do
              Link("#", "Default Link")
              Link("#", "Primary Link", variant: :primary)
              Link("#", "Secondary Link", variant: :secondary)
              Link("#", "Accent Link", variant: :accent)
              Link("#", "Neutral Link", variant: :neutral)
              Link("#", "Uppercase Link", uppercase: true)
            end

            code_example("Ruby Code", <<~RUBY.strip)
              Link("#", "Default Link")
              Link("#", "Primary Link", variant: :primary)
              Link("#", "Secondary Link", variant: :secondary)
              Link("#", "Accent Link", variant: :accent)
              Link("#", "Neutral Link", variant: :neutral)
              Link("#", "Uppercase Link", uppercase: true)
            RUBY
          end

          component_section("State Links", "Success, warning, error, and info link variants") do
            div(class: "flex flex-wrap gap-4") do
              Link("#", "Success Link", variant: :success)
              Link("#", "Warning Link", variant: :warning)
              Link("#", "Error Link", variant: :error)
              Link("#", "Info Link", variant: :info)
            end

            code_example("Ruby Code", <<~RUBY.strip)
              Link("#", "Success Link", variant: :success)
              Link("#", "Warning Link", variant: :warning)
              Link("#", "Error Link", variant: :error)
              Link("#", "Info Link", variant: :info)
            RUBY
          end

          component_section("Button Style & External Links", "Link as button and external link handling") do
            div(class: "flex flex-wrap items-center gap-4") do
              Link("#", "Button Style Link", variant: :button)
              Link("https://example.com", "External Link", external: true)
            end

            code_example("Ruby Code", 'Link("https://example.com", "External Link", external: true)')
          end
        end

        # Buttons Section
        section(id: "buttons") do
          h2(class: "text-2xl font-bold text-base-content mb-8 border-b border-base-300 pb-4") { "Button Components" }

          component_section("Button Variants", "Primary button styles for different contexts") do
            div(class: "flex flex-wrap gap-4") do
              Button(variant: :primary) { "Primary" }
              Button(variant: :secondary) { "Secondary" }
              Button(variant: :destructive) { "Destructive" }
              Button(variant: :success) { "Success" }
              Button(variant: :info) { "Info" }
              Button(variant: :warning) { "Warning" }
              Button(variant: :error) { "Error" }
            end

            code_example("Ruby Code", <<~RUBY.strip)
              Button(variant: :primary) { "Primary" }
              Button(variant: :secondary) { "Secondary" }
              Button(variant: :destructive) { "Destructive" }
              Button(variant: :success) { "Success" }
              Button(variant: :info) { "Info" }
              Button(variant: :warning) { "Warning" }
              Button(variant: :error) { "Error" }
            RUBY
          end



          component_section("Button Styles", "Outline, ghost, and link button variations") do
            div(class: "flex flex-wrap gap-4") do
              Button(variant: :outline) { "Outline" }
              Button(variant: :ghost) { "Ghost" }
              Button(variant: :link) { "Link Style" }
              Button(variant: :secondary, uppercase: true) { "Uppercase" }
            end

            code_example("Ruby Code", <<~RUBY.strip)
              Button(variant: :outline) { "Outline" }
              Button(variant: :ghost) { "Ghost" }
              Button(variant: :link) { "Link Style" }
              Button(variant: :secondary, uppercase: true) { "Uppercase" }
            RUBY
          end

          component_section("Button States", "Disabled buttons and submission patterns") do
            div(class: "space-y-4") do
              div(class: "flex flex-wrap gap-4") do
                Button(variant: :primary, disabled: true) { "Disabled" }
                SubmitButton("Submit Button", variant: :primary)
              end
            end

            code_example("Ruby Code", <<~RUBY.strip)
              Button(variant: :primary, disabled: true) { "Disabled" }
              SubmitButton("Submit Button", variant: :primary)
            RUBY
          end
        end

        # Form Input Components Section
        section(id: "form-inputs") do
          h2(class: "text-2xl font-bold text-base-content mb-8 border-b border-base-300 pb-4") { "Form Input Components" }

          component_section("Textarea Component", "Multi-line text input with validation states") do
            div(class: "space-y-4 max-w-md") do
              Textarea(
                name: "description",
                placeholder: "Enter your description here...",
                rows: 4
              )
              Textarea(
                name: "notes",
                placeholder: "Notes with error state...",
                rows: 3,
                class: "textarea-error",
                "aria-invalid": "true"
              )
            end
            code_example("Ruby Code", 'Textarea(name: "description", placeholder: "Enter description...", rows: 4)')
          end

          component_section("Size Variants", "DaisyUI size utilities applied via size option") do
            div(class: "grid md:grid-cols-2 gap-6 max-w-2xl") do
              div do
                h4(class: "font-medium mb-2") { "Input sizes" }
                div(class: "space-y-2") do
                  Input(name: "demo[default]", placeholder: "Default input")
                end
              end

              div do
                h4(class: "font-medium mb-2") { "Select" }
                div(class: "space-y-2") do
                  Select(name: "s[default]", options: %w[a b c])
                end
              end

              div do
                h4(class: "font-medium mb-2") { "Textarea" }
                div(class: "space-y-2") do
                  Textarea(name: "t[default]", rows: 2, placeholder: "Default")
                end
              end

              div do
                h4(class: "font-medium mb-2") { "Checkbox / Radio" }
                div(class: "space-y-2") do
                  div(class: "flex items-center gap-4") do
                    Checkbox(name: "c[default]", label: "Default")
                  end
                  Radio(name: "r[default]", options: [ [ "Option 1", "1" ], [ "Option 2", "2" ], [ "Option 3", "3" ] ])
                end
              end
            end

            code_example("Ruby Code", <<~RUBY.strip)
              Input()
              Select(size: :lg)
              Textarea(size: :sm)
              Checkbox(size: :lg)
              Radio(options: [["Small", "sm"], ["Default", "md"], ["Large", "lg"]], size: :sm)
            RUBY
          end

          component_section("Select Component", "Dropdown select with multiple options") do
            div(class: "space-y-4 max-w-md") do
              Select(
                name: "category",
                options: [
                  [ "Select a category...", "" ],
                  [ "Technology", "technology" ],
                  [ "Business", "business" ],
                  [ "Design", "design" ]
                ]
              )
              Select(
                name: "priority",
                options: [ [ "Low", "low" ], [ "Medium", "medium" ], [ "High", "high" ] ],
                selected: "medium"
              )
            end
            code_example("Ruby Code", 'Select(name: "category", options: [["Technology", "tech"], ["Business", "biz"]])')
          end

          component_section("Checkbox Component", "Single and multiple checkbox options") do
            div(class: "space-y-4") do
              div(class: "space-y-2") do
                Checkbox(
                  name: "newsletter",
                  value: "yes",
                  label: "Subscribe to newsletter"
                )
                Checkbox(
                  name: "terms",
                  value: "accepted",
                  label: "I agree to the terms and conditions",
                  required: true
                )
                Checkbox(
                  name: "disabled_option",
                  value: "unavailable",
                  label: "Disabled option",
                  disabled: true
                )
              end
            end
            code_example("Ruby Code", 'Checkbox(name: "newsletter", value: "yes", label: "Subscribe to newsletter")')
          end

          component_section("Radio Component", "Radio button groups for exclusive choices") do
            div(class: "space-y-4") do
              fieldset(class: "space-y-2") do
                legend(class: "text-sm font-medium mb-2") { "Account Type" }
                Radio(
                  name: "account_type",
                  options: [ [ "Personal Account", "personal" ], [ "Business Account", "business" ], [ "Enterprise Account", "enterprise" ] ],
                  selected: "personal"
                )
              end
            end
            code_example("Ruby Code", 'Radio(name: "account_type", options: [["Personal Account", "personal"], ["Business Account", "business"], ["Enterprise Account", "enterprise"]], selected: "personal")')
          end
        end

        # Form Components Section
        section(id: "form-components") do
          h2(class: "text-2xl font-bold text-base-content mb-8 border-b border-base-300 pb-4") { "Form Layout Components" }

          component_section("FormField Component", "Wrapper for form inputs with labels and validation") do
            div(class: "space-y-6 max-w-md") do
              FormField(
                label_text: "Email Address",
                name: "email",
                type: "email",
                placeholder: "user@example.com",
                help_text: "We'll never share your email"
              )
              FormField(
                label_text: "Password",
                name: "password",
                type: "password",
                help_text: "Must be at least 8 characters",
                required: true
              )
            end
            code_example("Ruby Code", 'FormField(label_text: "Email", name: "email", type: "email", help_text: "We\'ll never share your email")')
          end

          component_section("Complete Form Example", "Full form using FormCard and FormKit components") do
            FormCard(title: "User Registration Form") do
              div(class: "space-y-6") do
                EmailField(label_text: "Email Address", name: "email", placeholder: "user@example.com")
                PasswordField(label_text: "Password", name: "password", help_text: "At least 8 characters")

                div(class: "grid grid-cols-2 gap-4") do
                  FormField(label_text: "First Name", name: "first_name", placeholder: "John")
                  FormField(label_text: "Last Name", name: "last_name", placeholder: "Doe")
                end

                Textarea(name: "bio", placeholder: "Tell us about yourself...", rows: 3)

                Checkbox(name: "terms", value: "accepted", label: "I agree to the terms and conditions")

                div(class: "flex gap-4 pt-4") do
                  SubmitButton("Create Account", variant: :primary)
                  Button(variant: :secondary) { "Cancel" }
                end
              end
            end
          end
        end

        # Feedback Components Section
        section(id: "feedback") do
          h2(class: "text-2xl font-bold text-base-content mb-8 border-b border-base-300 pb-4") { "Feedback Components" }

          component_section("Alert Component", "Alert messages with different severity levels") do
            div(class: "space-y-4 max-w-2xl") do
              Alert(message: "Your changes have been saved successfully!", variant: :success)
              Alert(message: "This is important information you should know.", variant: :info)
              Alert(message: "Please review your input - something needs attention.", variant: :warning)
              Alert(message: "An error occurred while processing your request.", variant: :error)
            end
            code_example("Alert Variants", <<~RUBY.strip)
              Alert(message: "Saved successfully", variant: :success)
              Alert(message: "Informational notice", variant: :info)
              Alert(message: "Please review your input", variant: :warning)
              Alert(message: "An error occurred", variant: :error)
            RUBY
          end

          component_section("Dismissible Alerts", "Alert messages with close functionality") do
            div(class: "space-y-4 max-w-2xl") do
              Alert(
                message: "This alert can be dismissed by clicking the X button.",
                variant: :info,
                dismissible: true
              )
              Alert(
                message: "Dismissible warning alert with important information.",
                variant: :warning,
                dismissible: true
              )
            end
            code_example("Dismissible Alerts", <<~RUBY.strip)
              Alert(message: "Info alert", variant: :info, dismissible: true)
              Alert(message: "Warning alert", variant: :warning, dismissible: true)
            RUBY
          end

          component_section("Toast Component", "Toast notifications for temporary feedback") do
            div(class: "space-y-4") do
              p(class: "text-base-content/70 mb-4") { "Toast components are floating notifications that appear temporarily. Below are alert-style examples of their content (actual toasts would float in corners):" }

              div(class: "space-y-3 max-w-sm") do
                Alert(message: "Profile updated successfully!", variant: :success)
                Alert(message: "Connection restored", variant: :info)
                Alert(message: "Session will expire soon", variant: :warning)
                Alert(message: "Failed to save changes", variant: :error)
              end

              div(class: "mt-4 p-4 bg-base-200 rounded-lg") do
                h4(class: "font-semibold mb-2") { "Toast Usage" }
                p(class: "text-sm text-base-content/70 mb-2") { "Toasts are positioned floating containers that auto-dismiss after a set duration." }
                p(class: "text-sm text-base-content/70") { "They automatically integrate with Rails flash messages through the flash helper." }
              end
            end
            code_example("Toast Variants", <<~RUBY.strip)
              Toast(message: "Saved", variant: :success, position: "top-end")
              Toast(message: "Heads up", variant: :info, position: "bottom-center")
              Toast(message: "Warning", variant: :warning, position: "top-center", duration: 8000)
              Toast(message: "Error", variant: :error, position: "bottom-end", duration: 0)
            RUBY
          end
        end

        # Utility Components Section
        section(id: "utility") do
          h2(class: "text-2xl font-bold text-base-content mb-8 border-b border-base-300 pb-4") { "Utility Components" }

          component_section("Badge Component", "Badges with different colors, sizes, and styles") do
            div(class: "space-y-6") do
              # Badge variants
              div do
                h4(class: "font-medium mb-3") { "Badge Variants" }
                div(class: "flex flex-wrap gap-2") do
                  Badge(variant: :primary) { "Primary" }
                  Badge(variant: :secondary) { "Secondary" }
                  Badge(variant: :accent) { "Accent" }
                  Badge(variant: :neutral) { "Neutral" }
                  Badge(variant: :info) { "Info" }
                  Badge(variant: :success) { "Success" }
                  Badge(variant: :warning) { "Warning" }
                  Badge(variant: :error) { "Error" }
                end
              end
              code_example("Badge Variants", <<~RUBY.strip)
                Badge(variant: :primary) { "Primary" }
                Badge(variant: :secondary) { "Secondary" }
                Badge(variant: :accent) { "Accent" }
                Badge(variant: :neutral) { "Neutral" }
                Badge(variant: :info) { "Info" }
                Badge(variant: :success) { "Success" }
                Badge(variant: :warning) { "Warning" }
                Badge(variant: :error) { "Error" }
              RUBY

              # Badge sizes
              div do
                h4(class: "font-medium mb-3") { "Badge Sizes" }
                div(class: "flex flex-wrap items-center gap-3") do
                  Badge(variant: :primary, size: :xs) { "Extra Small" }
                  Badge(variant: :primary, size: :sm) { "Small" }
                  Badge(variant: :primary, size: :md) { "Medium" }
                  Badge(variant: :primary, size: :lg) { "Large" }
                end
              end
              code_example("Badge Sizes", <<~RUBY.strip)
                Badge(variant: :primary, size: :xs) { "Extra Small" }
                Badge(variant: :primary, size: :sm) { "Small" }
                Badge(variant: :primary, size: :md) { "Medium" }
                Badge(variant: :primary, size: :lg) { "Large" }
              RUBY

              # Badge styles
              div do
                h4(class: "font-medium mb-3") { "Badge Styles" }
                div(class: "flex flex-wrap gap-3") do
                  Badge(variant: :primary, style: :filled) { "Filled" }
                  Badge(variant: :primary, style: :outline) { "Outline" }
                  Badge(variant: :primary, style: :ghost) { "Ghost" }
                end
              end
              code_example("Badge Styles", <<~RUBY.strip)
                Badge(variant: :primary, style: :filled) { "Filled" }
                Badge(variant: :primary, style: :outline) { "Outline" }
                Badge(variant: :primary, style: :ghost) { "Ghost" }
              RUBY
            end
          end

          component_section("Loading Component", "Loading spinners for different contexts") do
            div(class: "space-y-6") do
              # Loading sizes
              div do
                h4(class: "font-medium mb-3") { "Loading Sizes" }
                div(class: "flex items-center gap-6") do
                  Loading(size: :sm)
                  Loading(size: :md)
                  Loading(size: :lg)
                end
              end
              code_example("Loading Sizes", <<~RUBY.strip)
                Loading(size: :sm)
                Loading(size: :md)
                Loading(size: :lg)
              RUBY

              # Loading with text
              div do
                h4(class: "font-medium mb-3") { "Loading with Messages" }
                div(class: "space-y-3") do
                  div(class: "flex items-center gap-3") do
                    Loading(size: :sm)
                    span(class: "text-sm text-base-content/70") { "Loading..." }
                  end
                  div(class: "flex items-center gap-3") do
                    Loading(size: :sm)
                    span(class: "text-sm text-base-content/70") { "Saving changes..." }
                  end
                end
              end
              code_example("Loading with Text", <<~RUBY.strip)
                Loading(size: :sm, text: "Loading...")
                Loading(size: :sm, text: "Saving changes...")
              RUBY
            end
          end
        end

        # Table Components Section
        section(id: "tables") do
          h2(class: "text-2xl font-bold text-base-content mb-8 border-b border-base-300 pb-4") { "Table Components" }

          component_section("Basic Table", "Simple data table with headers and rows") do
            Table(
              headers: [ "Name", "Email", "Role", "Status" ],
              data: [
                [ "John Doe", "john@example.com", "Admin", "Active" ],
                [ "Jane Smith", "jane@example.com", "User", "Active" ],
                [ "Mike Johnson", "mike@example.com", "Editor", "Inactive" ]
              ]
            )

            code_example("Ruby Code", <<~RUBY.strip)
              Table(
                headers: ["Name", "Email", "Role", "Status"],
                data: [
                  ["John Doe", "john@example.com", "Admin", "Active"],
                  ["Jane Smith", "jane@example.com", "User", "Active"]
                ]
              )
            RUBY
          end

          component_section("Industrial Table Variants", "Data-dense styling for technical applications") do
            div(class: "space-y-8") do
              # Industrial zebra striping
              div do
                h4(class: "font-medium mb-3") { "System Monitor - Zebra Striped" }
                Table(
                  variant: :zebra,
                  headers: [ "PID", "Process", "CPU%", "Memory", "Status", "Uptime" ],
                  data: [
                    [ "1432", "postgres", "12.3", "1.2GB", "RUNNING", "72:15:33" ],
                    [ "2891", "redis-server", "3.1", "256MB", "RUNNING", "48:22:15" ],
                    [ "3024", "nginx", "0.8", "128MB", "RUNNING", "91:03:42" ],
                    [ "3156", "sidekiq", "5.7", "512MB", "RUNNING", "12:45:28" ],
                    [ "4023", "webpack-dev", "18.4", "892MB", "RUNNING", "02:13:09" ]
                  ]
                )
              end

              # Dense data variant
              div do
                h4(class: "font-medium mb-3") { "Dense Data Table" }
                Table(
                  variant: :dense,
                  headers: [ "Node", "IP", "Load", "Mem", "Disk", "Net I/O", "Status" ],
                  data: [
                    [ "web-01", "10.0.1.12", "0.45", "78%", "23%", "1.2MB/s", "HEALTHY" ],
                    [ "web-02", "10.0.1.13", "0.67", "82%", "31%", "2.1MB/s", "HEALTHY" ],
                    [ "db-01", "10.0.2.10", "1.23", "94%", "67%", "15.7MB/s", "WARNING" ],
                    [ "cache-01", "10.0.3.15", "0.12", "34%", "8%", "0.8MB/s", "HEALTHY" ],
                    [ "lb-01", "10.0.0.5", "0.89", "45%", "12%", "45.2MB/s", "HEALTHY" ]
                  ]
                )
              end

              # Bordered technical data
              div do
                h4(class: "font-medium mb-3") { "Technical Specifications - Bordered" }
                Table(
                  variant: :bordered,
                  headers: [ "Component", "Model", "Spec", "Temp °C", "Voltage", "Status" ],
                  data: [
                    [ "CPU", "Intel i7-12700K", "3.6GHz 12C/20T", "42", "1.25V", "OPTIMAL" ],
                    [ "GPU", "RTX 4080", "16GB GDDR6X", "67", "12V", "OPTIMAL" ],
                    [ "RAM", "DDR5-5600", "32GB CL36", "35", "1.1V", "OPTIMAL" ],
                    [ "SSD", "Samsung 980 PRO", "2TB NVMe", "38", "3.3V", "OPTIMAL" ]
                  ]
                )
              end

              # Sticky header for data monitoring
              div do
                h4(class: "font-medium mb-3") { "Log Monitor - Sticky Headers" }
                div(class: "max-h-48 overflow-y-auto") do
                  Table(
                    variant: :pin_rows,
                    size: :sm,
                    headers: [ "Timestamp", "Level", "Service", "Message", "Source" ],
                    data: [
                      [ "2024-01-15T10:30:15Z", "INFO", "web-server", "Request processed successfully", "nginx" ],
                      [ "2024-01-15T10:30:16Z", "WARN", "database", "Connection pool near limit", "postgres" ],
                      [ "2024-01-15T10:30:17Z", "ERROR", "auth-service", "Invalid token provided", "oauth" ],
                      [ "2024-01-15T10:30:18Z", "INFO", "cache", "Cache miss, fetching from DB", "redis" ],
                      [ "2024-01-15T10:30:19Z", "DEBUG", "scheduler", "Job queued for processing", "sidekiq" ],
                      [ "2024-01-15T10:30:20Z", "INFO", "web-server", "Static asset served", "nginx" ],
                      [ "2024-01-15T10:30:21Z", "WARN", "monitoring", "Disk space below threshold", "system" ],
                      [ "2024-01-15T10:30:22Z", "INFO", "database", "Transaction committed", "postgres" ]
                    ]
                  )
                end
                p(class: "text-sm text-base-content/60 mt-2") { "Scroll to see sticky header effect" }
              end
            end

            code_example("Industrial Table Variants", <<~RUBY.strip)
              Table(variant: :zebra, headers: [...], data: [...])
              Table(variant: :dense, headers: [...], data: [...])    # Maximum data density
              Table(variant: :bordered, headers: [...], data: [...]) # Enhanced grid lines
              Table(variant: :pin_rows, headers: [...], data: [...]) # Sticky headers
            RUBY
          end

          component_section("Table Sizes", "Different table size options") do
            div(class: "space-y-8") do
              # Extra small table
              div do
                h4(class: "font-medium mb-3") { "Extra Small Table" }
                Table(
                  size: :xs,
                  headers: [ "#", "Task", "Status" ],
                  data: [
                    [ "1", "Review code", "Done" ],
                    [ "2", "Update docs", "In Progress" ]
                  ]
                )
              end

              # Large table
              div do
                h4(class: "font-medium mb-3") { "Large Table" }
                Table(
                  size: :lg,
                  headers: [ "Department", "Manager", "Budget", "Employees" ],
                  data: [
                    [ "Engineering", "Sarah Connor", "$500,000", "12" ],
                    [ "Marketing", "John Matrix", "$200,000", "6" ]
                  ]
                )
              end
            end

            code_example("Table Sizes", <<~RUBY.strip)
              Table(size: :xs, headers: [...], data: [...])
              Table(size: :sm, headers: [...], data: [...])
              Table(size: :md, headers: [...], data: [...])   # Default
              Table(size: :lg, headers: [...], data: [...])
            RUBY
          end

          component_section("Custom Table Structure", "Building tables with subcomponents") do
            p(class: "text-base-content/70 mb-4") { "Use table subcomponents for complete control over structure and styling:" }

            Table(variant: :zebra) do
              thead do
                tr do
                  render Components::Table::Header.new(sortable: true, sorted: :asc) { "Student" }
                  render Components::Table::Header.new(sortable: true) { "Score" }
                  render Components::Table::Header.new { "Grade" }
                  render Components::Table::Header.new { "Actions" }
                end
              end
              tbody do
                render Components::Table::Row.new(variant: :active) do
                  render Components::Table::Cell.new { "Alice Johnson" }
                  render Components::Table::Cell.new(align: :center) { "95" }
                  render Components::Table::Cell.new(align: :center) do
                    Badge(variant: :success) { "A" }
                  end
                  render Components::Table::Actions.new do
                    button(class: "btn btn-ghost btn-xs") { "Edit" }
                    button(class: "btn btn-ghost btn-xs") { "Delete" }
                  end
                end
                render Components::Table::Row.new do
                  render Components::Table::Cell.new { "Bob Wilson" }
                  render Components::Table::Cell.new(align: :center) { "87" }
                  render Components::Table::Cell.new(align: :center) do
                    Badge(variant: :warning) { "B+" }
                  end
                  render Components::Table::Actions.new do
                    button(class: "btn btn-ghost btn-xs") { "Edit" }
                    button(class: "btn btn-ghost btn-xs") { "Delete" }
                  end
                end
                render Components::Table::Row.new do
                  render Components::Table::Cell.new { "Carol Brown" }
                  render Components::Table::Cell.new(align: :center) { "78" }
                  render Components::Table::Cell.new(align: :center) do
                    Badge(variant: :info) { "C+" }
                  end
                  render Components::Table::Actions.new do
                    button(class: "btn btn-ghost btn-xs") { "Edit" }
                    button(class: "btn btn-ghost btn-xs") { "Delete" }
                  end
                end
              end
            end

            code_example("Custom Table Structure", <<~RUBY.strip)
              Table do
                thead do
                  tr do
                    render Components::Table::Header.new(sortable: true, sorted: :asc) { "Student" }
                    render Components::Table::Header.new(sortable: true) { "Score" }
                    render Components::Table::Header.new { "Actions" }
                  end
                end
                tbody do
                  render Components::Table::Row.new(variant: :active) do
                    render Components::Table::Cell.new { "Alice Johnson" }
                    render Components::Table::Cell.new(align: :center) { "95" }
                    render Components::Table::Actions.new do
                      button(class: "btn btn-ghost btn-xs") { "Edit" }
                      button(class: "btn btn-ghost btn-xs") { "Delete" }
                    end
                  end
                end
              end
            RUBY
          end

          component_section("Hash Data Rendering", "Tables with hash-based data") do
            div(class: "space-y-6") do
              p(class: "text-base-content/70") { "Tables can render hash data by matching keys to headers:" }

              Table(
                headers: [ "name", "age", "department", "salary" ],
                data: [
                  { "name" => "Alice Johnson", "age" => "28", "department" => "Engineering", "salary" => "$85,000" },
                  { "name" => "Bob Wilson", "age" => "35", "department" => "Design", "salary" => "$75,000" },
                  { "name" => "Carol Brown", "age" => "31", "department" => "Product", "salary" => "$90,000" }
                ]
              )
            end

            code_example("Hash Data", <<~RUBY.strip)
              Table(
                headers: ["name", "age", "department", "salary"],
                data: [
                  { "name" => "Alice", "age" => "28", "department" => "Engineering" },
                  { "name" => "Bob", "age" => "35", "department" => "Design" }
                ]
              )
            RUBY
          end

          component_section("Empty Table State", "Handling tables with no data") do
            div(class: "space-y-6") do
              p(class: "text-base-content/70") { "Tables gracefully handle empty data with a helpful message:" }

              Table(
                headers: [ "User", "Last Login", "Status" ],
                data: []
              )
            end

            code_example("Empty Table", <<~RUBY.strip)
              Table(
                headers: ["User", "Last Login", "Status"],
                data: []   # Shows "No data available" message
              )
            RUBY
          end

          component_section("Industrial Data Monitor", "Wide technical tables with horizontal scrolling") do
            div(class: "space-y-4") do
              p(class: "text-base-content/70 mb-4") { "Industrial monitoring dashboards often require wide data tables. This example shows server metrics with horizontal scrolling:" }

              div(class: "overflow-x-auto") do
                Table(
                  variant: :dense,
                  size: :sm,
                  headers: [ "Server", "IP Address", "Region", "CPU Load", "Memory", "Disk I/O", "Network In", "Network Out", "Connections", "Uptime", "Load Avg", "Processes", "Last Check", "Status", "Alerts", "Actions" ],
                  data: [
                    [ "prod-web-01", "172.16.1.10", "us-east-1a", "23.4%", "78.2%", "1.2MB/s", "45.6MB/s", "23.1MB/s", "156", "15d 4h 23m", "1.23", "87", "2024-01-15 14:30:15", "HEALTHY", "0", "SSH" ],
                    [ "prod-web-02", "172.16.1.11", "us-east-1b", "45.7%", "82.1%", "2.4MB/s", "67.8MB/s", "34.2MB/s", "203", "12d 18h 45m", "1.89", "92", "2024-01-15 14:30:18", "WARNING", "2", "SSH" ],
                    [ "prod-db-01", "172.16.2.10", "us-east-1a", "67.8%", "94.3%", "15.7MB/s", "12.3MB/s", "8.9MB/s", "45", "22d 7h 12m", "2.34", "34", "2024-01-15 14:30:12", "CRITICAL", "5", "SSH" ],
                    [ "prod-cache-01", "172.16.3.15", "us-east-1c", "12.1%", "34.7%", "0.8MB/s", "89.2MB/s", "67.4MB/s", "1,234", "8d 14h 56m", "0.45", "23", "2024-01-15 14:30:20", "HEALTHY", "0", "SSH" ],
                    [ "prod-lb-01", "172.16.0.5", "us-east-1a", "34.5%", "45.8%", "0.2MB/s", "156.7MB/s", "142.3MB/s", "2,789", "31d 2h 18m", "1.12", "15", "2024-01-15 14:30:16", "HEALTHY", "1", "SSH" ]
                  ]
                )
              end

              p(class: "text-sm text-base-content/60 mt-2") { "Dense variant optimizes space for maximum data visibility. Table scrolls horizontally on smaller screens." }
            end

            code_example("Industrial Data Table", <<~RUBY.strip)
              # Dense, scrollable industrial monitoring table
              div(class: "overflow-x-auto") do
                Table(
                  variant: :dense,   # Maximum data density for monitoring
                  size: :sm,        # Compact size for more rows visible
                  headers: ["Server", "IP", "CPU", "Memory", "Disk I/O", "Status"],
                  data: [
                    ["prod-web-01", "172.16.1.10", "23.4%", "78.2%", "1.2MB/s", "HEALTHY"]
                  ]
                )
              end
            RUBY
          end

          component_section("Table Actions", "Action buttons and dropdowns for table rows") do
            div(class: "space-y-6") do
              p(class: "text-base-content/70") { "Use the Actions component for clean, industrial-styled action buttons in table rows:" }

              Table(variant: :zebra, size: :sm) do
                thead do
                  tr do
                    render Components::Table::Header.new { "Server" }
                    render Components::Table::Header.new { "Status" }
                    render Components::Table::Header.new { "CPU" }
                    render Components::Table::Header.new { "Actions" }
                  end
                end
                tbody do
                  render Components::Table::Row.new do
                    render Components::Table::Cell.new { "prod-web-01" }
                    render Components::Table::Cell.new { Badge(variant: :success) { "ONLINE" } }
                    render Components::Table::Cell.new(align: :center) { "23%" }
                    render Components::Table::Actions.new do
                      button(class: "btn btn-ghost btn-xs") { "View" }
                      button(class: "btn btn-ghost btn-xs") { "Edit" }
                      button(class: "btn btn-ghost btn-xs") { "Stop" }
                    end
                  end
                  render Components::Table::Row.new do
                    render Components::Table::Cell.new { "prod-web-02" }
                    render Components::Table::Cell.new { Badge(variant: :warning) { "RESTART" } }
                    render Components::Table::Cell.new(align: :center) { "67%" }
                    render Components::Table::Actions.new do
                      button(class: "btn btn-ghost btn-xs") { "View" }
                      button(class: "btn btn-ghost btn-xs") { "Edit" }
                      button(class: "btn btn-ghost btn-xs") { "Stop" }
                    end
                  end
                  render Components::Table::Row.new do
                    render Components::Table::Cell.new { "prod-db-01" }
                    render Components::Table::Cell.new { Badge(variant: :error) { "ERROR" } }
                    render Components::Table::Cell.new(align: :center) { "89%" }
                    render Components::Table::Actions.new do
                      button(class: "btn btn-ghost btn-xs") { "View" }
                      button(class: "btn btn-ghost btn-xs") { "Edit" }
                      button(class: "btn btn-ghost btn-xs") { "Restart" }
                    end
                  end
                end
              end

              div(class: "mt-6") do
                h4(class: "font-medium mb-3") { "Actions with Pre-configured Items" }
                p(class: "text-sm text-base-content/60 mb-4") { "Actions component supports pre-configured button, link, and dropdown items:" }

                Table(size: :sm) do
                  thead do
                    tr do
                      render Components::Table::Header.new { "User" }
                      render Components::Table::Header.new { "Role" }
                      render Components::Table::Header.new { "Actions" }
                    end
                  end
                  tbody do
                    render Components::Table::Row.new do
                      render Components::Table::Cell.new { "admin@example.com" }
                      render Components::Table::Cell.new { "Administrator" }
                      render Components::Table::Actions.new(
                        items: [
                          { type: :link, text: "Profile", href: "/users/1" },
                          { type: :button, text: "Reset Password", attributes: { data: { action: "reset-password", user_id: "1" } } },
                          {
                            type: :dropdown,
                            items: [
                              { type: :button, text: "Deactivate", attributes: { data: { action: "deactivate", user_id: "1" } } },
                              { type: :button, text: "Delete", attributes: { data: { action: "delete", user_id: "1" } } }
                            ]
                          }
                        ]
                      )
                    end
                  end
                end
              end
            end

            code_example("Table Actions", <<~RUBY.strip)
              # Custom action buttons with blocks
              render Components::Table::Actions.new do
                button(class: "btn btn-ghost btn-xs") { "View" }
                button(class: "btn btn-ghost btn-xs") { "Edit" }
                button(class: "btn btn-ghost btn-xs") { "Delete" }
              end

              # Pre-configured action items
              render Components::Table::Actions.new(
                items: [
                  { type: :link, text: "View", href: "/items/1" },
                  { type: :button, text: "Edit", attributes: { data: { action: "edit", item_id: "1" } } },
                  {
                    type: :dropdown,
                    items: [
                      { type: :button, text: "Archive", attributes: { data: { action: "archive", item_id: "1" } } },
                      { type: :button, text: "Delete", attributes: { data: { action: "delete", item_id: "1" } } }
                    ]
                  }
                ]
              )

              # You can also use the Cell component with actions flag
              render Components::Table::Cell.new(actions: true) do
                # Custom action content
              end
            RUBY
          end
        end

        # Layout Components Section
        section(id: "layout") do
          h2(class: "text-2xl font-bold text-base-content mb-8 border-b border-base-300 pb-4") { "Layout Components" }

          component_section("Cards & Containers", "Card components for content organization") do
            div(class: "grid md:grid-cols-2 gap-6") do
              ExampleCard(title: "Example Card") do
                p(class: "text-base-content/70") { "This card demonstrates the surface and border tokens working in both light and dark modes." }
              end

              div(class: "card bg-base-100 shadow p-6") do
                h3(class: "text-lg font-semibold text-base-content mb-3") { "Custom Card" }
                p(class: "text-base-content/70 mb-4") { "This uses a typical elevated surface with custom styling." }
                Button(variant: :primary) { "Action" }
              end
            end
          end

          component_section("Navigation Components", "Dropdown menus and navigation elements") do
            div(class: "space-y-6") do
              h4(class: "font-medium mb-3") { "Dropdown Menu" }
              DropdownMenu(trigger_text: "Account Menu") do
                DropdownMenuItem("#", "Profile")
                DropdownMenuItem("#", "Settings")
                DropdownMenuItem("#", "Sign out", method: :delete, class: "text-error")
              end
            end
          end

          component_section("Auth Components", "Authentication-specific UI elements") do
            div(class: "space-y-6") do
              # Auth Links
              div do
                h4(class: "font-medium mb-3") { "Auth Links" }
                AuthLinks(links: [
                  { text: "Sign up", path: "#" },
                  { text: "Sign in", path: "#" },
                  { text: "Forgot password?", path: "#" }
                ])
              end

              # Recovery Codes
              div do
                h4(class: "font-medium mb-3") { "Recovery Codes" }
                ul(class: "grid grid-cols-2 gap-2 max-w-md") do
                  RecoveryCodeItem(code: "ABC123", used: false)
                  RecoveryCodeItem(code: "DEF456", used: true)
                  RecoveryCodeItem(code: "GHI789", used: false)
                  RecoveryCodeItem(code: "JKL012", used: false)
                end
              end
            end
          end
        end

        # Testing Infrastructure Section
        section(id: "testing") do
          h2(class: "text-2xl font-bold text-base-content mb-8 border-b border-base-300 pb-4") { "Testing Infrastructure" }

          component_section("Component Testing Patterns", "How to test Phlex components effectively") do
            div(class: "space-y-6") do
              div(class: "bg-base-200 rounded-lg p-6") do
                h4(class: "font-semibold mb-4") { "ComponentTestCase" }
                p(class: "text-base-content/70 mb-4") { "Base test case class for all component tests with helper methods:" }

                code_example("Test Example", <<~RUBY.strip
                  class Components::BadgeTest < ComponentTestCase
                    def test_renders_with_variant
                      component = Components::Badge.new(variant: :primary) { "Test Badge" }
                      assert_component_html component, includes: ['badge-primary', 'Test Badge']
                    end
                  end
                RUBY
                )
              end

              div(class: "bg-base-200 rounded-lg p-6") do
                h4(class: "font-semibold mb-4") { "Test Helpers Available" }
                ul(class: "space-y-2 text-sm") do
                  li { "• assert_component_html - Test rendered HTML output" }
                  li { "• assert_accessible - Verify ARIA compliance" }
                  li { "• assert_variant_classes - Check CSS classes" }
                  li { "• assert_component_renders - Ensure no render errors" }
                  li { "• with_mock_context - Simulate Rails context" }
                end
              end
            end
          end

          component_section("Testing Best Practices", "Guidelines for component testing") do
            div(class: "prose max-w-none") do
              div(class: "bg-base-200 rounded-lg p-6") do
                ul(class: "space-y-2") do
                  li { "✓ Test all variants and combinations" }
                  li { "✓ Verify accessibility attributes" }
                  li { "✓ Check error states and edge cases" }
                  li { "✓ Test Rails integration (flash messages, forms)" }
                  li { "✓ Ensure proper HTML structure" }
                  li { "✓ Validate component API contracts" }
                end
              end
            end
          end
        end

        # Style Guide Section
        section(id: "style-guide") do
          h2(class: "text-2xl font-bold text-base-content mb-8 border-b border-base-300 pb-4") { "Developer Style Guide" }

          component_section("Component Architecture", "How to build new Phlex components") do
            div(class: "space-y-6") do
              div(class: "bg-base-200 rounded-lg p-6") do
                h4(class: "font-semibold mb-4") { "Component Structure" }
                code_example("Component Template", <<~RUBY.strip
                  class Components::NewComponent < Components::Base
                    VARIANTS = {
                      primary: "new-primary",
                      secondary: "new-secondary"
                    }.freeze

                    def initialize(variant: :primary, **attributes)
                      @variant = variant
                      @attributes = attributes
                    end

                    def view_template(&block)
                      div(class: component_classes, **@attributes) do
                        yield if block
                      end
                    end

                    private

                    def component_classes
                      ["new-component", VARIANTS[@variant]].compact.join(" ")
                    end
                  end
                RUBY
                )
              end
            end
          end

          component_section("Naming Conventions", "Consistent naming patterns across components") do
            div(class: "bg-base-200 rounded-lg p-6") do
              h4(class: "font-semibold mb-4") { "Naming Standards" }
              ul(class: "space-y-2 text-sm") do
                li { "• Components: PascalCase (e.g., Components::FormField)" }
                li { "• Variants: snake_case symbols (e.g., :primary, :outline)" }
                li { "• CSS classes: Follow Daisy UI conventions" }
                li { "• Test files: component_name_test.rb" }
                li { "• Constants: SCREAMING_SNAKE_CASE (e.g., VARIANTS)" }
              end
            end
          end

          component_section("Integration Patterns", "Rails and accessibility integration") do
            div(class: "space-y-4") do
              div(class: "bg-base-200 rounded-lg p-6") do
                h4(class: "font-semibold mb-4") { "Rails Form Integration" }
                code_example("Form Helper Usage", <<~RUBY.strip
                  # In Rails forms, use components like this:
                  Components::FormField.new(
                    name: "user[email]",
                    label_text: "Email Address",
                    type: "email",
                    value: @user.email,
                    errors: @user.errors[:email]
                  )
                RUBY
                )
              end

              div(class: "bg-base-200 rounded-lg p-6") do
                h4(class: "font-semibold mb-4") { "Accessibility Requirements" }
                ul(class: "space-y-2 text-sm") do
                  li { "• Always include proper ARIA attributes" }
                  li { "• Use semantic HTML elements" }
                  li { "• Ensure keyboard navigation support" }
                  li { "• Provide alt text for images" }
                  li { "• Use appropriate color contrast ratios" }
                end
              end
            end
          end

          component_section("Performance Guidelines", "Component optimization best practices") do
            div(class: "bg-base-200 rounded-lg p-6") do
              h4(class: "font-semibold mb-4") { "Performance Best Practices" }
              ul(class: "space-y-2 text-sm") do
                li { "• Use frozen string literals" }
                li { "• Freeze constant hashes (VARIANTS.freeze)" }
                li { "• Minimize DOM nesting depth" }
                li { "• Cache expensive computations" }
                li { "• Use CSS classes instead of inline styles" }
                li { "• Avoid unnecessary re-renders" }
              end
            end
          end
        end
      end

      # Footer
      div(class: "mt-16 border-t border-base-300 bg-base-200 p-8") do
        div(class: "max-w-6xl mx-auto") do
          div(class: "text-center mb-6") do
            h3(class: "text-lg font-semibold mb-2") { "Phlex Component Library" }
            p(class: "text-base-content/70") { "All components automatically adapt to light and dark themes using semantic color tokens." }
          end

          div(class: "grid md:grid-cols-3 gap-6 text-sm") do
            div do
              h4(class: "font-semibold mb-2") { "Component Categories" }
              ul(class: "space-y-1 text-base-content/70") do
                li { "• Links & Buttons" }
                li { "• Form Inputs" }
                li { "• Feedback (Alerts & Toasts)" }
                li { "• Utility (Badge, Avatar, Loading)" }
              end
            end

            div do
              h4(class: "font-semibold mb-2") { "Features" }
              ul(class: "space-y-1 text-base-content/70") do
                li { "• Variant Support" }
                li { "• Accessibility Compliant" }
                li { "• Rails Integration" }
                li { "• Testing Infrastructure" }
              end
            end

            div do
              h4(class: "font-semibold mb-2") { "Development" }
              ul(class: "space-y-1 text-base-content/70") do
                li { "• ComponentTestCase" }
                li { "• Style Guide" }
                li { "• Best Practices" }
                li { "• Performance Guidelines" }
              end
            end
          end
        end
      end
    end
  end

  private

  # Navigation link helper
  def nav_link(text, href)
    Link(href, text, variant: :button, class: "btn-ghost")
  end

  # Component section wrapper
  def component_section(title, description = nil, &block)
    div(class: "space-y-6") do
      div do
        h3(class: "text-lg font-semibold text-base-content mb-2") { title }
        if description
          p(class: "text-sm text-base-content/70 mb-4") { description }
        end
      end
      yield if block
    end
  end

  # Code example display
  def code_example(title, code)
    div(class: "mt-4 bg-base-300 rounded-lg p-4") do
      div(class: "flex items-center justify-between mb-3") do
        h5(class: "font-medium text-sm") { title }
        button(
          class: "btn btn-ghost",
          "data-clipboard-target": "#code-#{title.downcase.gsub(' ', '-')}"
        ) { "Copy" }
      end
      pre(class: "text-xs text-base-content/80 overflow-x-auto", id: "code-#{title.downcase.gsub(' ', '-')}") do
        code { code }
      end
    end
  end
end
