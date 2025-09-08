# frozen_string_literal: true

module Views
  module Admin
    module Users
      class Index < Views::Base
        include Phlex::Rails::Helpers::LinkTo

        def initialize(users:)
          @users = users
        end

        def view_template
          page_with_title("Users") do
            h1(class: "text-xl font-bold mb-4") { "Users" }
            if @users.any?
              ul(class: "menu bg-base-200 rounded-box p-2") do
                @users.each do |user|
                  li do
                    link_to(user.email, admin_user_path(user))
                  end
                end
              end
            else
              div(class: "text-base-content/70") { "No users yet." }
            end
          end
        end
      end
    end
  end
end
