# frozen_string_literal: true

class Components::Base < Phlex::HTML
  # Include the Components kit for clean component rendering
  include Components

  # Include any helpers you want to be available across all components
  include Phlex::Rails::Helpers::Routes

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end

  protected

  # Helper method to generate HTML IDs from form field names
  # Converts "user[email]" to "user_email"
  def generate_id_from_name(name)
    name.to_s.gsub(/[\[\]]/, "_").gsub(/__+/, "_").chomp("_")
  end
end
