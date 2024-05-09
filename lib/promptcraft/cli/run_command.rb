require "io/wait"
require "langchain"
require "tty-option"

# Pick an LLM provider + model:
#   promptcraft --provider groq
#   promptcraft --provider openai --model gpt-3.5-turbo
# Pass in a prompt via CLI (-p,--prompt expects a string, or filename)
#   promptcraft -c tmp/maths/start/basic.yml -p "I'm terrible at maths. If I'm asked a maths question, I reply with a question."
#   promptcraft -c tmp/maths/start/basic.yml -p <(echo "I'm terrible at maths. If I'm asked a maths question, I reply with a question.")
# The prompt file can also be YAML with system_prompt: key.
class Promptcraft::Cli::RunCommand
  include TTY::Option

  usage do
    program "promptcraft"

    command "run"

    desc "Re-run conversation against new system prompt"
  end

  option :conversation do
    arity zero_or_more
    short "-c"
    long "--conversation filename"
    desc "Filename of conversation (or use STDIN)"
  end

  option :prompt do
    short "-p"
    long "--prompt prompt"
    desc "String or filename containing system prompt"
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
    long "--provider provider_name"
    desc "Provider name to use for chat completion"
  end

  option :format do
    short "-f"
    long "--format format"
    desc "Output format (yaml, json)"
    default "yaml"
  end

  def run(stdin: nil)
    if params[:help]
      print help
    elsif params.errors.any?
      puts params.errors.summary
    else
      conversations = (params[:conversation] || []).each_with_object([]) do |filename, convos|
        Promptcraft::Conversation.load_from_file(filename)
        convos.push(*Promptcraft::Conversation.load_from_file(filename))
      end

      # if STDIN piped into the command, read stream of YAML conversations from STDIN
      if stdin&.ready?
        conversations.push(*Promptcraft::Conversation.load_from_io(stdin))
      end

      if conversations.empty?
        conversations << Promptcraft::Conversation.new(system_prompt: "You are helpful. If you're first, then ask a question. You like brevity.")
      end

      if (prompt = params[:prompt])
        # if prompt is a file, load it; else set the prompt to the value
        new_system_prompt = if File.exist?(prompt)
          File.read(prompt)
        else
          prompt
        end

        # If new_system_prompt is YAML and a Hash, use "system_prompt" key
        begin
          obj = YAML.load(new_system_prompt, symbolize_keys: true)
          if obj.is_a?(Hash) && obj[:system_prompt]
            new_system_prompt = obj[:system_prompt]
          end
        rescue
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
        if params[:format] == "json"
          puts conversation.to_json
        else
          puts conversation.to_yaml
        end
      end
    end
  end
end
