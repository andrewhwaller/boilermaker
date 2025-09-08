# frozen_string_literal: true

module Views
  module Admin
    module Accounts
      class Index < Views::Base
        include Phlex::Rails::Helpers::LinkTo

        def initialize(accounts:)
          @accounts = accounts
        end

        def view_template
          page_with_title("Accounts") do
            h1(class: "text-xl font-bold mb-4") { "Accounts" }
            if @accounts.any?
              ul(class: "menu bg-base-200 rounded-box p-2") do
                @accounts.each do |account|
                  li do
                    link_to(account.name || "(unnamed)", admin_account_path(account))
                  end
                end
              end
            else
              div(class: "text-base-content/70") { "No accounts yet." }
            end
          end
        end
      end
    end
  end
end
