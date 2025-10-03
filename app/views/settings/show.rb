# frozen_string_literal: true

module Views
 module Settings
 class Show < Views::Base
 include Phlex::Rails::Helpers::TurboFrameTag
 include ActionView::Helpers::DateHelper

 def initialize
 end

 def view_template
 page_with_title("Settings") do
 div(class: "flex items-start justify-between mb-4") do
 h1(class: "font-bold text-base-content ") { "User Settings" }
 end

 div(class: "max-w-xl space-y-6") do
 render Components::Card.new(title: "Email", header_color: :primary) do
 turbo_frame_tag "profile_settings", class: "block" do
 render Views::Identity::Emails::EditFrame.new(user: Current.user)
 end
 end

 render Components::Card.new(title: "Password", header_color: :primary) do
 turbo_frame_tag "password_settings", class: "block" do
 render Views::Passwords::EditFrame.new(user: Current.user)
 end
 end
 end
 end
 end
 end
 end
end
