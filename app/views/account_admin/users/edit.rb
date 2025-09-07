# frozen_string_literal: true

module Views
  module AccountAdmin
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
                h1(class: "text-2xl font-bold text-base-content") { "Edit User" }
                div(class: "flex gap-2") do
                  link_to("View User", account_admin_user_path(@user), class: "btn btn-outline")
                  link_to("Back to Users", account_admin_users_path, class: "btn btn-ghost")
                end
              end

              # User form
              card do
                h2(class: "text-lg font-semibold text-base-content mb-6") { "User Information" }

                form_errors(@user)

                form_with(model: [@user], url: account_admin_user_path(@user), local: true, class: "space-y-4") do |f|
                  # Email field
                  div do
                    f.label :email, class: "label"
                    f.email_field :email, class: "input input-bordered w-full", required: true
                    helper_text("The user's email address. Used for login and notifications.")
                  end

                  # Admin toggle
                  div do
                    label(class: "label cursor-pointer justify-start gap-3") do
                      f.check_box :admin, class: "checkbox checkbox-primary"
                      div do
                        span(class: "label-text font-medium") { "Account Administrator" }
                        div(class: "text-xs text-base-content/70") do
                          "Grant this user administrative privileges for this account"
                        end
                      end
                    end
                  end

                  # Verified status toggle
                  div do
                    label(class: "label cursor-pointer justify-start gap-3") do
                      f.check_box :verified, class: "checkbox checkbox-success"
                      div do
                        span(class: "label-text font-medium") { "Email Verified" }
                        div(class: "text-xs text-base-content/70") do
                          "Mark this user's email as verified"
                        end
                      end
                    end
                  end

                  # Current user warning
                  if @user == Current.user
                    div(class: "alert alert-info") do
                      div do
                        strong { "Note: " }
                        plain("You are editing your own account. Be careful when changing admin privileges.")
                      end
                    end
                  end

                  # Submit button
                  div(class: "flex gap-3 pt-4") do
                    f.submit "Update User", class: "btn btn-primary"
                    link_to("Cancel", account_admin_user_path(@user), class: "btn btn-outline")
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