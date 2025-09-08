# frozen_string_literal: true

module Views
  module Admin
    module Users
      class Show < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::TimeAgoInWords

        def initialize(user:)
          @user = user
        end

        def view_template
          page_with_title("User") do
            div(class: "flex items-center justify-between mb-4") do
              h1(class: "text-xl font-bold") { @user.email }
              link_to("All Users", admin_users_path, class: "btn btn-sm")
            end

            div(class: "bg-base-200 rounded-box p-4") do
              div { "ID: #{@user.id}" }
              div { "Verified: #{@user.verified?}" }
              div { "App Admin: #{@user.admin?}" }
              div { "Created: #{time_ago_in_words(@user.created_at)} ago" }
            end
          end
        end
      end
    end
  end
end
