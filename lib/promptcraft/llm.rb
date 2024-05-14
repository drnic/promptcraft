require "active_support/core_ext/module/delegation"

class Promptcraft::Llm
  DEFAULT_PROVIDER = "groq"

  attr_reader :langchain
  attr_accessor :provider, :model, :temperature

  delegate_missing_to :langchain

  def initialize(provider: DEFAULT_PROVIDER, model: nil, temperature: nil, api_key: nil)
    @provider = provider
    @temperature = temperature
    @langchain = case provider
    when "groq"
      @model = model || "llama3-70b-8192"
      require "openai"
      Langchain::LLM::OpenAI.new(
        api_key: api_key || ENV.fetch("GROQ_API_KEY"),
        llm_options: {uri_base: "https://api.groq.com/openai/"},
        default_options: {
          temperature: temperature,
          chat_completion_model_name: @model
        }.compact
      )
    when "openai"
      @model = model || "gpt-3.5-turbo"
      require "openai"
      Langchain::LLM::OpenAI.new(
        api_key: api_key || ENV.fetch("OPENAI_API_KEY"),
        default_options: {
          temperature: temperature,
          chat_completion_model_name: @model
        }.compact
      )
    when "openrouter"
      @model = model || "meta-llama/llama-3-8b-instruct:free"
      require "openai"
      Langchain::LLM::OpenAI.new(
        api_key: api_key || ENV.fetch("OPENROUTER_API_KEY"),
        llm_options: {uri_base: "https://openrouter.ai/api/"},
        default_options: {
          temperature: temperature,
          chat_completion_model_name: @model
        }.compact
      )
    when "ollama"
      @model = model || "llama3"
      Langchain::LLM::Ollama.new(
        default_options: {
          completion_model_name: @model,
          chat_completion_model_name: @model
        }
      )
    end
  end

  def to_h
    {provider:, model:, temperature:}.compact
  end

  def self.from_h(hash)
    new(provider: hash[:provider], model: hash[:model], temperature: hash[:temperature])
  end
end
