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
            ThemeToggle
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
              headers: ["Name", "Email", "Role", "Status"],
              data: [
                ["John Doe", "john@example.com", "Admin", "Active"],
                ["Jane Smith", "jane@example.com", "User", "Active"],
                ["Mike Johnson", "mike@example.com", "Editor", "Inactive"]
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

          component_section("Table Variants", "Different table styling options") do
            div(class: "space-y-8") do
              # Zebra striping
              div do
                h4(class: "font-medium mb-3") { "Zebra Striped Table" }
                Table(
                  variant: :zebra,
                  headers: ["Product", "Price", "Stock"],
                  data: [
                    ["Laptop", "$999", "5"],
                    ["Mouse", "$25", "50"],
                    ["Keyboard", "$75", "20"],
                    ["Monitor", "$299", "8"]
                  ]
                )
              end

              # Pin rows (sticky header)
              div do
                h4(class: "font-medium mb-3") { "Sticky Header Table" }
                div(class: "max-h-48 overflow-y-auto") do
                  Table(
                    variant: :pin_rows,
                    headers: ["ID", "Name", "Status", "Created"],
                    data: [
                      ["001", "Project Alpha", "Active", "2024-01-15"],
                      ["002", "Project Beta", "Active", "2024-01-20"],
                      ["003", "Project Gamma", "Pending", "2024-01-25"],
                      ["004", "Project Delta", "Active", "2024-02-01"],
                      ["005", "Project Echo", "Completed", "2024-02-05"],
                      ["006", "Project Foxtrot", "Active", "2024-02-10"]
                    ]
                  )
                end
                p(class: "text-sm text-base-content/60 mt-2") { "Scroll to see sticky header effect" }
              end
            end

            code_example("Table Variants", <<~RUBY.strip)
              Table(variant: :zebra, headers: [...], data: [...])
              Table(variant: :pin_rows, headers: [...], data: [...])
              Table(variant: :pin_cols, headers: [...], data: [...])
            RUBY
          end

          component_section("Table Sizes", "Different table size options") do
            div(class: "space-y-8") do
              # Extra small table
              div do
                h4(class: "font-medium mb-3") { "Extra Small Table" }
                Table(
                  size: :xs,
                  headers: ["#", "Task", "Status"],
                  data: [
                    ["1", "Review code", "Done"],
                    ["2", "Update docs", "In Progress"]
                  ]
                )
              end

              # Large table
              div do
                h4(class: "font-medium mb-3") { "Large Table" }
                Table(
                  size: :lg,
                  headers: ["Department", "Manager", "Budget", "Employees"],
                  data: [
                    ["Engineering", "Sarah Connor", "$500,000", "12"],
                    ["Marketing", "John Matrix", "$200,000", "6"]
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
                  render Components::Table::Cell.new(align: :center) do
                    div(class: "flex gap-1 justify-center") do
                      Button(variant: :outline, class: "btn-xs") { "Edit" }
                      Button(variant: :destructive, class: "btn-xs") { "Delete" }
                    end
                  end
                end
                render Components::Table::Row.new do
                  render Components::Table::Cell.new { "Bob Wilson" }
                  render Components::Table::Cell.new(align: :center) { "87" }
                  render Components::Table::Cell.new(align: :center) do
                    Badge(variant: :warning) { "B+" }
                  end
                  render Components::Table::Cell.new(align: :center) do
                    div(class: "flex gap-1 justify-center") do
                      Button(variant: :outline, class: "btn-xs") { "Edit" }
                      Button(variant: :destructive, class: "btn-xs") { "Delete" }
                    end
                  end
                end
                render Components::Table::Row.new do
                  render Components::Table::Cell.new { "Carol Brown" }
                  render Components::Table::Cell.new(align: :center) { "78" }
                  render Components::Table::Cell.new(align: :center) do
                    Badge(variant: :info) { "C+" }
                  end
                  render Components::Table::Cell.new(align: :center) do
                    div(class: "flex gap-1 justify-center") do
                      Button(variant: :outline, class: "btn-xs") { "Edit" }
                      Button(variant: :destructive, class: "btn-xs") { "Delete" }
                    end
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
                    render Components::Table::Cell.new(align: :center) do
                      div(class: "flex gap-1 justify-center") do
                        Button(variant: :outline, class: "btn-xs") { "Edit" }
                        Button(variant: :destructive, class: "btn-xs") { "Delete" }
                      end
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
                headers: ["name", "age", "department", "salary"],
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
                headers: ["User", "Last Login", "Status"],
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

          component_section("Responsive Table", "Tables with responsive behavior") do
            div(class: "space-y-4") do
              p(class: "text-base-content/70 mb-4") { "Wide tables automatically scroll horizontally on smaller screens. Try resizing your browser window or viewing on mobile:" }
              
              div(class: "overflow-x-auto") do
                Table(
                  variant: :zebra,
                  size: :sm,
                  headers: ["ID", "Product Name", "SKU", "Category", "Brand", "Price", "Cost", "Margin", "Stock", "Reserved", "Available", "Last Updated", "Status", "Supplier", "Location", "Actions"],
                  data: [
                    ["001", "MacBook Pro 16-inch M3 Max", "MBP16M3MAX", "Laptops", "Apple", "$3,499", "$2,800", "20%", "5", "2", "3", "2024-01-15 10:30", "In Stock", "Apple Inc", "Warehouse A", "Edit"],
                    ["002", "Dell XPS 13 Developer Edition", "XPS13DEV", "Laptops", "Dell", "$1,299", "$950", "27%", "12", "1", "11", "2024-01-20 14:45", "In Stock", "Dell Direct", "Warehouse B", "Edit"],
                    ["003", "ThinkPad X1 Carbon Gen 11", "X1C11", "Laptops", "Lenovo", "$1,899", "$1,400", "26%", "8", "0", "8", "2024-01-18 09:15", "In Stock", "Lenovo Corp", "Warehouse A", "Edit"],
                    ["004", "iPhone 15 Pro Max 1TB", "IP15PM1TB", "Smartphones", "Apple", "$1,599", "$1,200", "25%", "25", "5", "20", "2024-01-22 11:20", "In Stock", "Apple Inc", "Warehouse C", "Edit"],
                    ["005", "AirPods Max Silver", "APMAX-SLV", "Audio", "Apple", "$549", "$380", "31%", "8", "2", "6", "2024-01-18 16:30", "Low Stock", "Apple Inc", "Warehouse C", "Edit"]
                  ]
                )
              end
              
              p(class: "text-sm text-base-content/60 mt-2") { "This table will scroll horizontally when the content exceeds the container width." }
            end

            code_example("Responsive Table", <<~RUBY.strip)
              # Wrap table in scrollable container for wide tables
              div(class: "overflow-x-auto") do
                Table(
                  variant: :zebra,
                  size: :sm,
                  headers: ["ID", "Product", "SKU", "Category", "Brand", "Price", "Stock"],
                  data: [
                    ["001", "MacBook Pro 16-inch M3 Max", "MBP16M3MAX", "Laptops", "Apple", "$3,499", "5"]
                  ]
                )
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
                DropdownMenuItem("Profile", "#")
                DropdownMenuItem("Settings", "#")
                DropdownMenuItem("Sign out", "#", method: :delete, class: "text-error")
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
