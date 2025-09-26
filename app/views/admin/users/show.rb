# frozen_string_literal: true

module Views
  module Admin
    module Users
      class Show < Views::Base
        include Phlex::Rails::Helpers::LinkTo
        include Phlex::Rails::Helpers::TimeAgoInWords
        include Phlex::Rails::Helpers::Pluralize

        def initialize(user:)
          @user = user
        end

        def view_template
          page_with_title("User Details") do
            div(class: "space-y-6") do
              div(class: "flex items-center justify-between mb-6") do
                div(class: "flex items-center gap-4") do
                  link_to("← All Users", admin_users_path, class: "text-sm text-base-content/70 hover:text-primary")
                  h1(class: "font-bold text-base-content") { "User Details" }
                end
              end

              card do
                div(class: "flex items-start gap-6") do
                  div(class: "avatar placeholder") do
                    div(class: "bg-primary text-primary-content w-16 rounded-full") do
                      span(class: "text-xl") { @user.email[0].upcase }
                    end
                  end

                  div(class: "flex-1") do
                    h2(class: "font-semibold text-base-content mb-2") { @user.email }

                    div(class: "flex flex-wrap gap-2 mb-4") do
                      if @user.verified?
                        Badge(variant: :success) { "Verified" }
                      else
                        Badge(variant: :warning) { "Unverified" }
                      end

                      if @user.admin?
                        Badge(variant: :error) { "App Admin" }
                      else
                        Badge(variant: :ghost) { "User" }
                      end
                    end

                    div(class: "grid grid-cols-2 gap-4 text-sm") do
                      div do
                        div(class: "text-base-content/70") { "User ID" }
                        div(class: "font-medium font-mono") { @user.hashid }
                      end

                      div do
                        div(class: "text-base-content/70") { "Account" }
                        div(class: "font-medium") { @user.account.name || "Default Account" }
                      end

                      div do
                        div(class: "text-base-content/70") { "Joined" }
                        div(class: "font-medium") do
                          plain("#{time_ago_in_words(@user.created_at)} ago")
                        end
                        div(class: "text-xs text-base-content/50") do
                          plain(@user.created_at.strftime("%B %d, %Y at %I:%M %p"))
                        end
                      end

                      div do
                        div(class: "text-base-content/70") { "Updated" }
                        div(class: "font-medium") do
                          plain("#{time_ago_in_words(@user.updated_at)} ago")
                        end
                        div(class: "text-xs text-base-content/50") do
                          plain(@user.updated_at.strftime("%B %d, %Y at %I:%M %p"))
                        end
                      end
                    end
                  end
                end
              end

              card do
                h3(class: "font-semibold text-base-content mb-4") { "Account Information" }

                div(class: "grid grid-cols-2 gap-4 text-sm") do
                  div do
                    div(class: "text-base-content/70") { "Total Users in Account" }
                    div(class: "font-medium") do
                      plain(pluralize(@user.account.users.count, "user"))
                    end
                  end

                  div do
                    div(class: "text-base-content/70") { "Account Created" }
                    div(class: "font-medium") do
                      plain("#{time_ago_in_words(@user.account.created_at)} ago")
                    end
                  end
                end
              end

              if @user.sessions.any?
                card do
                  h3(class: "font-semibold text-base-content mb-4") { "Recent Sessions" }

                  div(class: "space-y-2") do
                    @user.sessions.order(created_at: :desc).limit(5).each do |session|
                      div(class: "flex justify-between items-center py-2 border-b border-base-300 last:border-b-0") do
                        div do
                          div(class: "text-sm font-medium") { "Session" }
                          div(class: "text-xs text-base-content/70") do
                            plain("Started #{time_ago_in_words(session.created_at)} ago")
                          end
                        end
                        div(class: "text-xs text-base-content/50 font-mono") do
                          plain(session.ip_address)
                        end
                      end
                    end
                  end

                  if @user.sessions.count > 5
                    div(class: "mt-4 text-center") do
                      p(class: "text-sm text-base-content/70") do
                        plain("and #{@user.sessions.count - 5} more sessions...")
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
