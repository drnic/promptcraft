require "tty-option"
require "langchain"

class Promptcraft::Cli::RunCommand
  include TTY::Option

  usage do
    program "promptcraft"

    command "run"

    desc "Re-run conversation against new system prompt"
  end

  option :directory do
    # required
    short "-d"
    long "--dir path"
    desc "Directory for prompt and conversation files"
  end

  option :conversation do
    required
    short "-c"
    long "--conversation filename"
    desc "Filename of conversation"
  end

  flag :help do
    short "-h"
    long "--help"
    desc "Print usage"
  end

  option :model do
    short "-m"
    long "--model model_name"
    desc "Model name to use for chat completion"
  end

  option :provider do
    short "-p"
    long "--provider provider_name"
    desc "Provider name to use for chat completion"
    default "groq"
  end

  def run
    if params[:help]
      print help
    elsif params.errors.any?
      puts params.errors.summary
    else
      llm = case params[:provider]
      when "groq"
        Langchain::LLM::OpenAI.new(
          api_key: ENV.fetch("GROQ_API_KEY"),
          llm_options: {uri_base: "https://api.groq.com/openai/"},
          default_options: {chat_completion_model_name: params[:model] || "llama3-70b-8192"}
        )
      when "openai"
        Langchain::LLM::OpenAI.new(
          api_key: ENV.fetch("OPENAI_API_KEY"),
          default_options: {chat_completion_model_name: params[:model] || "gpt-3.5-turbo"}
        )
      when "ollama"
        Langchain::LLM::Ollama.new(
          default_options: {
            completion_model_name: params[:model] || "llama3",
            chat_completion_model_name: params[:model] || "llama3"
          }
        )
      end

      pp params.to_h
      # It will find latest iteration
      # It will check if latest iteration is complete or not
      # If it is not complete, it will continue from where it left
      conversation = Promptcraft::Conversation.load_from_file(params[:conversation])
      messages = conversation.to_messages
      response = Promptcraft::Command::LlmChatCommand.new(messages:, llm:).execute
      pp response
    end
  end
end
