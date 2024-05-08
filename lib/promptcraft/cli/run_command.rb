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
    arity one_or_more
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
  end

  def run
    if params[:help]
      print help
    elsif params.errors.any?
      puts params.errors.summary
    else
      conversations = params[:conversation].each_with_object([]) do |filename, convos|
        Promptcraft::Conversation.load_from_file(filename)
        convos.push(*Promptcraft::Conversation.load_from_file(filename))
      end

      if (prompt = params[:prompt])
        # if prompt is a file, load it; else set the prompt to the value
        new_system_prompt = if File.exist?(prompt)
          File.read(prompt)
        else
          prompt
        end
      end

      # TODO: Rechat loop could be threaded to run many rechat conversations at once
      updated_conversations = conversations.map do |conversation|
        llm = if params[:provider]
          Promptcraft::Llm.new(provider: params[:provider], model: params[:model])
        elsif conversation.llm
          conversation.llm
        else
          Promptcraft::Llm.new
        end

        system_prompt = new_system_prompt || conversation.system_prompt

        cmd = Promptcraft::Command::RechatConversationCommand.new(system_prompt:, conversation:, llm:)
        cmd.execute
        cmd.updated_conversation
      end

      # Output. Currently we just output each conversation to the console as YAML
      updated_conversations.each do |conversation|
        puts conversation.to_yaml
      end
    end
  end
end
