# frozen_string_literal: true

RubyLLM.configure do |config|
  config.openai_api_key = Rails.application.credentials.dig(:openai, :api_key)
  config.openrouter_api_key = Rails.application.credentials.dig(:openrouter, :api_key)
end
