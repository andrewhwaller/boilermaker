# frozen_string_literal: true

module Views
  module Account
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
              # Header
              div(class: "flex items-center justify-between mb-6") do
                h1(class: "text-2xl font-bold text-base-content") { "User Details" }
                div(class: "flex gap-2") do
                  link_to("Edit User", edit_account_user_path(@user), class: "btn btn-primary")
                  link_to("Back to Users", account_users_path, class: "btn btn-outline")
                end
              end

              # User info card
              card do
                div(class: "flex items-start gap-6") do
                  div(class: "avatar placeholder") do
                    div(class: "bg-primary text-primary-content w-16 rounded-full") do
                      span(class: "text-xl") { @user.email[0].upcase }
                    end
                  end

                  div(class: "flex-1") do
                    h2(class: "text-xl font-semibold text-base-content mb-2") { @user.email }

                    div(class: "flex flex-wrap gap-2 mb-4") do
                      if @user.verified?
                        span(class: "badge badge-success") { "Verified" }
                      else
                        span(class: "badge badge-warning") { "Unverified" }
                      end

                      if @user.account_admin_for?(Current.user.account)
                        span(class: "badge badge-primary") { "Admin" }
                      else
                        span(class: "badge badge-ghost") { "Member" }
                      end

                      if @user == Current.user
                        span(class: "badge badge-info") { "Current User" }
                      end
                    end

                    div(class: "grid grid-cols-2 gap-4 text-sm") do
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

              # Sessions info card
              if @user.sessions.any?
                card do
                  h3(class: "text-lg font-semibold text-base-content mb-4") { "Active Sessions" }

                  div(class: "space-y-2") do
                    @user.sessions.order(created_at: :desc).limit(5).each do |session|
                      div(class: "flex justify-between items-center py-2 border-b border-base-300 last:border-b-0") do
                        div do
                          div(class: "text-sm font-medium") do
                            if session == Current.session
                              span(class: "text-primary") { "Current session" }
                            else
                              "Session"
                            end
                          end
                          div(class: "text-xs text-base-content/70") do
                            plain("Started #{time_ago_in_words(session.created_at)} ago")
                          end
                        end
                        div(class: "text-xs text-base-content/50") do
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

              # Account info
              card do
                h3(class: "text-lg font-semibold text-base-content mb-4") { "Account Information" }

                div(class: "grid grid-cols-2 gap-4 text-sm") do
                  div do
                    div(class: "text-base-content/70") { "Account Name" }
                    div(class: "font-medium") { @user.account.name || "Default Account" }
                  end

                  div do
                    div(class: "text-base-content/70") { "Total Users in Account" }
                    div(class: "font-medium") do
                      plain(pluralize(@user.account.users.count, "user"))
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
