# frozen_string_literal: true

class Components::Account::UserTable < Components::Base
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::TimeAgoInWords

  def initialize(users:, compact: false)
    @users = users
    @compact = compact
  end

  def view_template
    if @users.any?
      div(class: "overflow-x-auto") do
        table(class: "w-full") do
          thead do
            tr(class: "border-b border-base-300/30") do
              th(class: "text-left py-2 px-3 font-medium uppercase tracking-wide text-base-content/60") { "Name" }
              th(class: "text-left py-2 px-2 font-medium uppercase tracking-wide text-base-content/60") { "Email" }
              th(class: "text-left py-2 px-2 font-medium uppercase tracking-wide text-base-content/60") { "Status" }
              th(class: "text-left py-2 px-2 font-medium uppercase tracking-wide text-base-content/60") { "Role" }
              unless @compact
                th(class: "text-right py-2 px-2 font-medium uppercase tracking-wide text-base-content/60") { "Sessions" }
              end
              th(class: "text-right py-2 px-2 font-medium uppercase tracking-wide text-base-content/60") { "Joined" }
              th(class: "text-right py-2 px-2 font-medium uppercase tracking-wide text-base-content/60") { "Actions" }
            end
          end

          tbody do
            @users.each do |user|
              tr(class: "hover:bg-base-200/30 border-b border-base-300/20") do
                # Name column
                td(class: "py-3 px-3 font-medium") do
                  if user.first_name && user.last_name
                    plain("#{user.first_name} #{user.last_name}")
                    if user == Current.user
                      span(class: "text-primary ml-1") { "YOU" }
                    end
                  else
                    span(class: "text-base-content/40") { "—" }
                  end
                end

                # Email column
                td(class: "py-3 px-2 text-base-content/80") do
                  plain(user.email)
                end

                # Status column
                td(class: "py-3 px-2") do
                  span(class: "font-medium text-success uppercase tracking-wide") { "Verified" }
                end

                # Role column
                td(class: "py-3 px-2") do
                  if user.account_admin_for?(Current.user.account)
                    span(class: "font-medium text-primary uppercase tracking-wide") { "Admin" }
                  end
                end

                # Sessions column (only in full mode)
                unless @compact
                  td(class: "py-3 px-2 text-right font-mono") { user.sessions.count }
                end

                # Joined column
                td(class: "py-3 px-2 text-right font-mono text-base-content/70") { user.created_at.strftime("%m/%d/%Y") }

                # Actions column
                td(class: "py-3 px-2 text-right") do
                  div(class: "flex justify-end gap-3") do
                    link_to("EDIT", edit_account_user_path(user),
                      class: "text-base-content/70 hover:underline")
                  end
                end
              end
            end
          end
        end
      end
    else
      div(class: "text-center py-8 bg-base-200 rounded-box") do
        p(class: "text-base-content/70 mb-4") { "No verified users yet." }
      end
    end
  end
end
