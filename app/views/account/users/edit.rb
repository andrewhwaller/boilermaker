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
            div(class: "mb-4") do
              link_to(
                "Return to Account",
                account_dashboard_path,
                class: "\1"
              )
            end

            div(class: "flex items-start justify-between mb-4") do
              h1(class: "\1") { "Edit User" }
            end

            div(class: "flex flex-col gap-6") do
              render Components::Card.new(title: "User Information") do
                form_errors(@user)

                form_with(
                  model: [ @user ],
                  url: account_user_path(@user),
                  local: true,
                  class: "space-y-4"
                ) do |f|
                  div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
                    div(class: "space-y-1") do
                      f.label :first_name, "First Name", class: "label"
                      f.text_field :first_name, class: "ui-input", placeholder: "First name"
                    end

                    div(class: "space-y-1") do
                      f.label :last_name, "Last Name", class: "label"
                      f.text_field :last_name, class: "ui-input", placeholder: "Last name"
                    end
                  end

                  div(class: "space-y-1") do
                    f.label :email, "Email Address", class: "label"
                    f.email_field :email, class: "ui-input", required: true
                    helper_text("The user's email address. Used for login and notifications.")
                  end

                  div(class: "grid grid-cols-1 md:grid-cols-2 gap-4 pt-4 border-t border-line") do
                    div do
                      label(class: "label") { "Verification Status" }
                      div(class: "flex items-center gap-2") do
                        if @user.verified?
                          span(class: "text-success font-medium text-sm") { "Verified" }
                        else
                          span(class: "text-warning font-medium text-sm") { "Pending Verification" }
                        end
                      end
                    end

                    div do
                      label(class: "label") { "Member Since" }
                      div(class: "text-sm text-body") { formatted_date(@user.created_at) }
                    end
                  end

                  div(class: "pt-4") do
                    f.submit "Update User", class: "ui-button ui-button-primary"
                    link_to("Cancel", account_dashboard_path, class: "ui-button ui-button-outline ml-3")
                  end
                end
              end

              render Components::Card.new(title: "Account Role") do
                membership = @user.membership_for(Current.account)

                unless Current.account.owner == @user
                  form_with(
                    url: account_user_path(@user),
                    method: :patch,
                    local: true,
                    class: "space-y-3",
                    data: { controller: "auto-submit" }
                  ) do |f|
                    div do
                      label(class: "flex items-center gap-3 cursor-pointer") do
                        input(
                          type: "radio",
                          name: "role",
                          value: "admin",
                          checked: membership&.admin? || false,
                          class: "ui-radio",
                          data: { action: "change->auto-submit#submit" }
                        )

                        div do
                          span(class: "\1") { "Admin" }
                          div(class: "text-xs text-muted") { "Can manage users and account settings" }
                        end
                      end
                    end

                    div do
                      label(class: "flex items-center gap-3 cursor-pointer") do
                        input(
                          type: "radio",
                          name: "role",
                          value: "member",
                          checked: !(membership&.admin?) || false,
                          class: "ui-radio",
                          data: { action: "change->auto-submit#submit" }
                        )

                        div do
                          span(class: "\1") { "Member" }
                          div(class: "text-xs text-muted") { "Standard user access" }
                        end
                      end
                    end
                  end
                else
                  div(class: "flex items-center gap-3") do
                    input(type: "radio", disabled: true, checked: true, class: "ui-radio")

                    div do
                      span(class: "\1") { "Owner" }
                      div(class: "text-xs text-muted") { "Account owner with full privileges" }
                    end
                  end
                end

                if @user == Current.user
                  div(class: "ui-alert ui-alert-info mt-4") do
                    div do
                      strong { "Note: " }
                      plain "You are editing your own account. Be careful when changing privileges."
                    end
                  end
                end
              end

              unless @user == Current.user
                render Components::Card.new(title: "Danger Zone", class: "border-destructive/30") do
                  div do
                    h4(class: "font-medium text-body mb-2") { "Remove User from Account" }
                    p(class: "text-sm text-muted mb-4") do
                      plain "This will remove #{@user.email} from this account. They will lose access to all account resources."
                    end

                    form_with(
                      url: account_user_path(@user),
                      method: :delete,
                      local: true,
                      class: "inline"
                    ) do |f|
                      f.submit(
                        "Remove User",
                        class: "ui-button ui-button-error",
                        confirm: "Are you sure you want to remove #{@user.email} from this account? This action cannot be undone."
                      )
                    end
                  end
                end
              end
            end
          end
        end

        private


        def formatted_date(value)
          value.strftime("%b %d %Y").upcase
        end
      end
    end
  end
end
