module Promptcraft::Llm
  extend self
  DEFAULT_PROVIDER = "groq"

  def langchain(provider: DEFAULT_PROVIDER, model: nil, &)
    @llm = case provider
    when "groq"
      Langchain::LLM::OpenAI.new(
        api_key: ENV.fetch("GROQ_API_KEY"),
        llm_options: {uri_base: "https://api.groq.com/openai/"},
        default_options: {chat_completion_model_name: model || "llama3-70b-8192"},
        &
      )
    when "openai"
      Langchain::LLM::OpenAI.new(
        api_key: ENV.fetch("OPENAI_API_KEY"),
        default_options: {chat_completion_model_name: model || "gpt-3.5-turbo"},
        &
      )
    when "ollama"
      Langchain::LLM::Ollama.new(
        default_options: {
          completion_model_name: model || "llama3",
          chat_completion_model_name: model || "llama3"
        },
        &
      )
    end
  end
end
