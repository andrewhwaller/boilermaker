# frozen_string_literal: true

module Views
  module Invitations
    class New < Views::Base
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::LinkTo

      def initialize(user:)
        @user = user
      end

      def view_template
        if notice
          p(class: "text-success") { plain(notice) }
        end

        h1 { "Send invitation" }

        form_with(url: invitation_path) do |form|
          if @user.errors.any?
            div(class: "text-error") do
              h2 do
                plain(pluralize(@user.errors.count, "error"))
                plain(" prohibited this user from being saved:")
              end

              ul do
                @user.errors.each do |error|
                  li { plain(error.full_message) }
                end
              end
            end
          end

          div do
            form.label(:email, class: "block")
            form.email_field(:email, required: true, autofocus: true)
          end

          div do
            form.submit("Send an invitation")
          end
        end

        br

        div do
          link_to("Back", root_path)
        end
      end
    end
  end
end
