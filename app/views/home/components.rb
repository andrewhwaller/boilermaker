# frozen_string_literal: true

class Views::Home::Components < Views::Base
  def view_template
    div(class: "min-h-screen bg-white dark:bg-gray-900") do
      # Theme Toggle Bar
      div(class: "sticky top-0 bg-gray-50 dark:bg-gray-800 border-b border-border p-4 z-10") do
        div(class: "flex items-center justify-between max-w-4xl mx-auto") do
          h1(class: "text-2xl font-bold text-base-content") { "Component Showcase" }
          div(class: "flex items-center gap-4") do
            p(class: "text-sm text-base-content-muted") { "Toggle dark mode to test themes" }

            button(
              type: "button",
              class: "px-4 py-2 rounded border border-border bg-button text-button-text hover:bg-button-hover transition-colors",
            ) { "Toggle Dark Mode" }
          end
        end
      end

      # Main Content
      div(class: "max-w-4xl mx-auto p-8 space-y-12") do
        # Buttons Section
        section do
          h2(class: "text-xl font-semibold text-base-content mb-6 border-b border-border pb-2") { "Buttons" }
          div(class: "grid gap-6") do
            # Button variants
            div(class: "space-y-4") do
              h3(class: "text-lg font-medium text-base-content") { "Button Variants" }
              div(class: "flex flex-wrap gap-4") do
                Components::Button.new(variant: :primary) { "Primary Button" }
                Components::Button.new(variant: :secondary) { "Secondary Button" }
                Components::Button.new(variant: :destructive) { "Destructive Button" }
                Components::Button.new(variant: :outline) { "Outline Button" }
                Components::Button.new(variant: :ghost) { "Ghost Button" }
                Components::Button.new(variant: :link) { "Link Button" }
              end
            end

            # Button states
            div(class: "space-y-4") do
              h3(class: "text-lg font-medium text-base-content") { "Button States" }
              div(class: "flex flex-wrap gap-4") do
                Components::Button.new(variant: :primary, disabled: true) { "Disabled Button" }
                Components::SubmitButton.new("Submit Button", variant: :primary)
              end
            end
          end
        end

        # Forms Section
        section do
          h2(class: "text-xl font-semibold text-base-content mb-6 border-b border-border pb-2") { "Form Components" }
          Components::FormCard.new(title: "Example Form") do
            div(class: "space-y-6") do
              Components::EmailField.new(label_text: "Email Address", name: "email", placeholder: "user@example.com")
              Components::PasswordField.new(label_text: "Password", name: "password", help_text: "At least 8 characters")
              Components::FormGroup.new(label_text: "Full Name", name: "name", placeholder: "Enter your full name", help_text: "This will be displayed publicly")

              div(class: "flex gap-4") do
                Components::SubmitButton.new("Save Changes", variant: :primary)
                Components::Button.new(variant: :secondary) { "Cancel" }
              end
            end
          end
        end

        # Cards Section
        section do
          h2(class: "text-xl font-semibold text-base-content mb-6 border-b border-border pb-2") { "Cards & Layout" }
          div(class: "grid md:grid-cols-2 gap-6") do
            Components::ExampleCard.new(title: "Example Card") do
              p(class: "text-base-content-muted") { "This card demonstrates the surface and border tokens working in both light and dark modes." }
            end

            div(class: "surface-elevated rounded-lg p-6") do
              h3(class: "text-lg font-semibold text-base-content mb-3") { "Elevated Surface" }
              p(class: "text-base-content-muted") { "This uses the .surface-elevated utility class." }
            end
          end
        end

        # Dropdowns Section
        section do
          h2(class: "text-xl font-semibold text-base-content mb-6 border-b border-border pb-2") { "Navigation & Dropdowns" }
          div(class: "space-y-6") do
            h3(class: "text-lg font-medium text-base-content") { "Dropdown Menu" }
            Components::DropdownMenu.new(trigger_text: "Account Menu") do
              Components::DropdownMenuItem.new("Profile", "#")
              Components::DropdownMenuItem.new("Settings", "#")
              Components::DropdownMenuItem.new("Sign out", "#", method: :delete, class: "text-error")
            end
          end
        end

        # Colors Section
        section do
          h2(class: "text-xl font-semibold text-base-content mb-6 border-b border-border pb-2") { "Color Tokens" }
          div(class: "grid md:grid-cols-2 gap-8") do
            # Background colors
            div do
              h3(class: "text-lg font-medium text-base-content mb-4") { "Backgrounds" }
              div(class: "space-y-3") do
                color_sample("bg-white dark:bg-gray-900", "Background")
                color_sample("bg-gray-50 dark:bg-gray-800", "Surface")
                color_sample("bg-white dark:bg-gray-900-elevated", "Elevated")
              end
            end

            # Text colors
            div do
              h3(class: "text-lg font-medium text-base-content mb-4") { "Text" }
              div(class: "space-y-3") do
                color_text_sample("text-base-content", "Foreground")
                color_text_sample("text-base-content-muted", "Muted")
                color_text_sample("text-base-content-subtle", "Subtle")
              end
            end

            # State colors
            div do
              h3(class: "text-lg font-medium text-base-content mb-4") { "States" }
              div(class: "space-y-3") do
                state_sample("success")
                state_sample("error")
                state_sample("warning")
                state_sample("info")
              end
            end
          end
        end

        # Auth Links Section
        section do
          h2(class: "text-xl font-semibold text-base-content mb-6 border-b border-border pb-2") { "Auth Components" }
          Components::AuthLinks.new(links: [
            { text: "Sign up", path: "#" },
            { text: "Sign in", path: "#" },
            { text: "Forgot password?", path: "#" }
          ])
        end

        # Recovery Codes Section
        section do
          h2(class: "text-xl font-semibold text-base-content mb-6 border-b border-border pb-2") { "Recovery Codes" }
          ul(class: "grid grid-cols-2 gap-2") do
            Components::RecoveryCodeItem.new(code: "ABC123", used: false)
            Components::RecoveryCodeItem.new(code: "DEF456", used: true)
            Components::RecoveryCodeItem.new(code: "GHI789", used: false)
            Components::RecoveryCodeItem.new(code: "JKL012", used: false)
          end
        end
      end

      # Footer
      div(class: "mt-16 border-t border-border bg-gray-50 dark:bg-gray-800 p-8") do
        div(class: "max-w-4xl mx-auto text-center") do
          p(class: "text-base-content-muted") { "All components automatically adapt to light and dark themes using semantic color tokens." }
        end
      end
    end
  end

  private

  def color_sample(bg_class, name)
    div(class: "flex items-center gap-3") do
      div(class: "w-8 h-8 rounded border border-border #{bg_class}")
      span(class: "text-sm text-base-content") { name }
      code(class: "text-xs text-base-content-muted font-mono") { bg_class }
    end
  end

  def color_text_sample(text_class, name)
    div(class: "flex items-center gap-3") do
      span(class: "#{text_class}") { "Sample text" }
      span(class: "text-sm text-base-content") { name }
      code(class: "text-xs text-base-content-muted font-mono") { text_class }
    end
  end

  def state_sample(state)
    div(class: "alert-#{state} p-3 rounded") do
      span(class: "text-sm font-medium") { "#{state.capitalize} message" }
    end
  end
end
