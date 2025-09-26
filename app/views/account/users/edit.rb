# frozen_string_literal: true

module Views
  module Account
    module Users
      class Edit < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::FormWith

        def initialize(user:)
          @user = user
        end

        def view_template
          page_with_title("Edit User") do
            div(class: "space-y-6") do
              # Header
              div(class: "flex items-center justify-between mb-6") do
                div(class: "flex items-center gap-4") do
                  link_to("← Back to Account", account_path, class: "text-sm text-base-content/70 hover:text-primary")
                  h1(class: "text-2xl font-bold text-base-content") { "Edit User" }
                end
              end

              # User Information Card
              div(class: "bg-base-200 border border-base-300 rounded-box overflow-hidden shadow-sm") do
                div(class: "p-6") do
                  h2(class: "font-semibold text-base-content uppercase mb-6") { "User Information" }

                  form_errors(@user)

                  # User attributes form
                  form_with(model: [ @user ], url: account_user_path(@user), local: true, class: "space-y-6") do |f|
                    # Email field
                    div do
                      f.label :email, "Email Address", class: "label"
                      f.email_field :email, class: "input input-bordered w-full", required: true
                      helper_text("The user's email address. Used for login and notifications.")
                    end

                    # Action buttons for user attributes
                    div(class: "flex gap-3 pt-6 border-t border-base-300") do
                      f.submit "Update User", class: "btn btn-primary"
                      link_to("Cancel", account_path, class: "btn btn-outline")
                    end
                  end

                  # Separate form for role management
                  membership = @user.membership_for(Current.user.account)
                  unless membership&.owner?
                    div(class: "mt-6 pt-6 border-t border-base-300") do
                      label(class: "label") do
                        span(class: "label-text font-medium") { "Account Role" }
                      end

                      form_with(url: account_user_path(@user), method: :patch, local: true, class: "space-y-3", data: { controller: "auto-submit" }) do |f|
                        # Admin role
                        div do
                          label(class: "flex items-center gap-3 cursor-pointer") do
                            input(
                              type: "radio",
                              name: "role",
                              value: "admin",
                              checked: membership&.admin? || false,
                              class: "radio radio-primary",
                              data: { action: "change->auto-submit#submit" }
                            )
                            div do
                              span(class: "text-sm font-medium uppercase") { "Admin" }
                              div(class: "text-xs text-base-content/70") { "Can manage users and account settings" }
                            end
                          end
                        end

                        # Member role
                        div do
                          label(class: "flex items-center gap-3 cursor-pointer") do
                            input(
                              type: "radio",
                              name: "role",
                              value: "member",
                              checked: !(membership&.admin?) || false,
                              class: "radio radio-primary",
                              data: { action: "change->auto-submit#submit" }
                            )
                            div do
                              span(class: "text-sm font-medium uppercase") { "Member" }
                              div(class: "text-xs text-base-content/70") { "Standard user access" }
                            end
                          end
                        end
                      end
                    end
                  else
                    # Show owner role as non-editable
                    div(class: "mt-6 pt-6 border-t border-base-300") do
                      label(class: "label") do
                        span(class: "label-text font-medium") { "Account Role" }
                      end
                      div(class: "flex items-center gap-3") do
                        input(type: "radio", disabled: true, checked: true, class: "radio radio-primary")
                        div do
                          span(class: "text-sm font-medium text-primary uppercase") { "Owner" }
                          div(class: "text-xs text-base-content/70") { "Account owner with full privileges" }
                        end
                      end
                    end
                  end

                  # Current user warning
                  if @user == Current.user
                    div(class: "alert alert-info mt-6") do
                      div do
                        strong { "Note: " }
                        plain("You are editing your own account. Be careful when changing privileges.")
                      end
                    end
                  end
                end
              end

              # Danger Zone (only show for non-current users)
              unless @user == Current.user
                div(class: "bg-base-200 border border-error/30 rounded-box overflow-hidden shadow-sm") do
                  div(class: "p-6") do
                    h3(class: "font-semibold text-error uppercase mb-4") { "Danger Zone" }

                    div(class: "space-y-4") do
                      div do
                        h4(class: "font-medium text-base-content mb-2") { "Remove User from Account" }
                        p(class: "text-sm text-base-content/70 mb-4") do
                          plain("This will remove #{@user.email} from this account. They will lose access to all account resources.")
                        end

                        form_with(url: account_user_path(@user), method: :delete, local: true, class: "inline") do |f|
                          f.submit "Remove User",
                            class: "btn btn-error btn-outline",
                            confirm: "Are you sure you want to remove #{@user.email} from this account? This action cannot be undone."
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end

        private

        def helper_text(text)
          div(class: "text-xs text-base-content/70 mt-1") { text }
        end
      end
    end
  end
end
