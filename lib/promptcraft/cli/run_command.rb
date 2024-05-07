require "tty-option"
require "langchain"

# Pick an LLM provider + model:
#   promptcraft --provider groq
#   promptcraft --provider openai --model gpt-3.5-turbo
# Pass in a prompt via CLI (-p,--prompt expects a filename so can use <(echo "..."))
#   promptcraft -c tmp/maths/start/basic.yml -p <(echo "I'm terrible at maths. If I'm asked a maths question, I reply with a question.")
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

  option :prompt do
    # required
    short "-p"
    long "--prompt filename"
    desc "Filename of system prompt"
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
    # short "-p"
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
      llm = Promptcraft::Llm.langchain(provider: params[:provider], model: params[:model])

      pp params.to_h
      # It will find latest iteration
      # It will check if latest iteration is complete or not
      # If it is not complete, it will continue from where it left
      conversation = Promptcraft::Conversation.load_from_file(params[:conversation])

      if (prompt_file = params[:prompt])
        prompt = File.read(prompt_file)
        conversation.system_prompt = prompt
      end

      messages = conversation.to_messages
      response = Promptcraft::Command::LlmChatCommand.new(messages:, llm:).execute

      # expect response to be a Hash with role and content keys
      # expect response[:role] to be "assistant"
      # expect response[:content] to be a String
      conversation.messages << response
      puts conversation.to_yaml
    end
  end
end
