# frozen_string_literal: true

RubyLLM.configure do |config|
  config.openai_api_key = Rails.application.credentials.dig(:openai, :api_key)
  config.openrouter_api_key = Rails.application.credentials.dig(:openrouter, :api_key)
end

unless Rails.env.test?
  if Rails.application.credentials.dig(:openai, :api_key).blank?
    Rails.logger.warn "WARNING: OpenAI API key is not configured. Embeddings will not work."
  end

  if Rails.application.credentials.dig(:openrouter, :api_key).blank?
    Rails.logger.warn "WARNING: OpenRouter API key is not configured. Research assistant will not work."
  end
end
