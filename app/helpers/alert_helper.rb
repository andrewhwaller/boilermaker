# frozen_string_literal: true

module AlertHelper
  # Map Rails flash message types to Alert component variants
  FLASH_TO_VARIANT = {
    "notice" => :success,
    "alert" => :error,
    "success" => :success,
    "error" => :error,
    "warning" => :warning,
    "info" => :info
  }.freeze

  # Render all flash messages as Alert components
  # @return [Array<Components::Alert>] Array of Alert components for each flash message
  def render_flash_alerts
    flash.filter_map do |type, message|
      next if message.blank?

      variant = FLASH_TO_VARIANT[type.to_s] || :info
      Components::Alert.new(message: message, variant: variant, dismissible: true)
    end
  end

  # Create an Alert component with flash-style configuration
  # @param message [String] The message to display
  # @param variant [Symbol] The alert variant (:success, :error, :warning, :info)
  # @param dismissible [Boolean] Whether the alert can be dismissed
  # @param options [Hash] Additional options to pass to the Alert component
  # @return [Components::Alert] Alert component instance
  def flash_alert(message, variant: :info, dismissible: true, **options)
    Components::Alert.new(
      message: message,
      variant: variant,
      dismissible: dismissible,
      **options
    )
  end

  # Convert Rails flash type to Alert variant
  # @param flash_type [String, Symbol] Rails flash message type
  # @return [Symbol] Corresponding Alert variant
  def flash_type_to_variant(flash_type)
    FLASH_TO_VARIANT[flash_type.to_s] || :info
  end

  # Check if a flash type should be rendered as an error
  # @param flash_type [String, Symbol] Rails flash message type
  # @return [Boolean] Whether this flash type represents an error
  def flash_type_error?(flash_type)
    [ "alert", "error" ].include?(flash_type.to_s)
  end

  # Check if a flash type should be rendered as a success
  # @param flash_type [String, Symbol] Rails flash message type
  # @return [Boolean] Whether this flash type represents success
  def flash_type_success?(flash_type)
    [ "notice", "success" ].include?(flash_type.to_s)
  end
end
