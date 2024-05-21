require "active_support/core_ext/module/delegation"

class Promptcraft::Llm
  DEFAULT_PROVIDER = "groq"

  attr_reader :langchain
  attr_accessor :provider, :model, :temperature

  delegate_missing_to :langchain

  def initialize(provider: nil, model: nil, temperature: nil, api_key: nil)
    @provider = provider
    @temperature = temperature
    @api_key = api_key

    select_provider_and_model

    @langchain = case @provider
    when "groq"
      require "openai"
      Langchain::LLM::OpenAI.new(
        api_key: @api_key || ENV.fetch("GROQ_API_KEY"),
        llm_options: {uri_base: "https://api.groq.com/openai/"},
        default_options: {
          temperature: temperature,
          chat_completion_model_name: @model
        }.compact
      )
    when "openai"
      require "openai"
      Langchain::LLM::OpenAI.new(
        api_key: @api_key || ENV.fetch("OPENAI_API_KEY"),
        default_options: {
          temperature: temperature,
          chat_completion_model_name: @model
        }.compact
      )
    when "openrouter"
      require "openai"
      Langchain::LLM::OpenAI.new(
        api_key: @api_key || ENV.fetch("OPENROUTER_API_KEY"),
        llm_options: {uri_base: "https://openrouter.ai/api/"},
        default_options: {
          temperature: temperature,
          chat_completion_model_name: @model
        }.compact
      )
    when "ollama"
      Langchain::LLM::Ollama.new(
        default_options: {
          completion_model_name: @model,
          chat_completion_model_name: @model
        }
      )
    else
      raise "No valid API key found for any provider."
    end
  end

  def select_provider_and_model
    if @api_key
      @provider ||= "openai" # Default to openai if api_key is explicitly provided
    else
      @provider ||= if ENV["GROQ_API_KEY"]
                      "groq"
                    elsif ENV["OPENAI_API_KEY"]
                      "openai"
                    elsif ENV["OPENROUTER_API_KEY"]
                      "openrouter"
                    else
                      raise "No valid API key found for any provider."
                    end
    end

    @model ||= case @provider
               when "groq" then "llama3-70b-8192"
               when "openai" then "gpt-3.5-turbo"
               when "openrouter" then "meta-llama/llama-3-8b-instruct:free"
               when "ollama" then "llama3"
               end
  end

  def to_h
    {provider:, model:, temperature:}.compact
  end

  def self.from_h(hash)
    new(provider: hash[:provider], model: hash[:model], temperature: hash[:temperature], api_key: hash[:api_key])
  end
end
