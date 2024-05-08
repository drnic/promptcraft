require "active_support/core_ext/module/delegation"

class Promptcraft::Llm
  DEFAULT_PROVIDER = "groq"

  attr_reader :llm, :provider, :model

  delegate_missing_to :llm

  def initialize(provider: DEFAULT_PROVIDER, model: nil)
    @provider = provider
    @llm = case provider
    when "groq"
      @model = model || "llama3-70b-8192"
      Langchain::LLM::OpenAI.new(
        api_key: ENV.fetch("GROQ_API_KEY"),
        llm_options: {uri_base: "https://api.groq.com/openai/"},
        default_options: {chat_completion_model_name: @model}
      )
    when "openai"
      @model = model || "gpt-3.5-turbo"
      Langchain::LLM::OpenAI.new(
        api_key: ENV.fetch("OPENAI_API_KEY"),
        default_options: {chat_completion_model_name: @model}
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
    {provider: provider, model: model}
  end

  def self.from_h(hash)
    new(provider: hash[:provider], model: hash[:model])
  end
end
