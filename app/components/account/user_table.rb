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
      Table(variant: :zebra, size: @compact ? :xs : :sm) do
        thead do
          tr do
            th { "Name" }
            th { "Email" }
            th { "Status" }
            th { "Role" }
            th { "Sessions" } unless @compact
            th { "Joined" }
            th { "Actions" }
          end
        end

        tbody do
          @users.each do |user|
            tr do
              td { user_name(user) }
              td { user.email }
              td { span(class: "text-success font-medium uppercase text-xs") { "Verified" } }
              td { user_role(user) }
              td { user.sessions.count } unless @compact
              td { user.created_at.strftime("%m/%d/%Y") }
              td { link_to("Edit", edit_account_user_path(user), class: "btn btn-ghost btn-xs") }
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

  private

  def user_name(user)
    if user.first_name && user.last_name
      name = "#{user.first_name} #{user.last_name}"
      user == Current.user ? "#{name} (YOU)" : name
    else
      "—"
    end
  end

  def user_role(user)
    span(class: "text-primary font-medium uppercase text-xs") { "Admin" } if user.account_admin_for?(Current.user.account)
  end
end
