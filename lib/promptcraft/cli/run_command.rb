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
  end

  def run
    if params[:help]
      print help
    elsif params.errors.any?
      puts params.errors.summary
    else
      conversation = Promptcraft::Conversation.load_from_file(params[:conversation])

      if params[:provider]
        llm = Promptcraft::Llm.new(provider: params[:provider], model: params[:model])
        conversation.llm = llm
      elsif conversation.llm
        llm = conversation.llm
      else
        params[:provider] = "groq"
        llm = Promptcraft::Llm.new(provider: params[:provider], model: params[:model])
        conversation.llm = llm
      end

      system_prompt =
        if (prompt = params[:prompt])
          # if prompt is a file, load it; else set the prompt to the value
          if File.exist?(prompt)
            File.read(prompt)
          else
            prompt
          end
        else
          conversation.system_prompt
        end
      warn "No system prompt provided." unless system_prompt

      # TODO: --conversation is an array of filenames
      # and the output is multiple YAML documents combined
      #
      # and --conversation can also load multiple YAML documents from one file
      # docs = %(---\nhi: 1\n---\nthere: 2\n)
      # docs.split("---\n").map {|doc| YAML.load(doc)}.compact
      # => [{"hi"=>1}, {"there"=>2}]
      #
      # Rechat could be threaded to run many rechat conversations at once

      cmd = Promptcraft::Command::RechatConversationCommand.new(system_prompt: system_prompt, conversation: conversation, llm: llm)
      cmd.execute
      puts cmd.updated_conversation.to_yaml
    end
  end
end
