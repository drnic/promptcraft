require "yaml"

class Promptcraft::Conversation
  include Promptcraft::Helpers
  extend Promptcraft::Helpers

  attr_accessor :system_prompt, :messages
  attr_accessor :llm

  def initialize(system_prompt:, messages: [], llm: nil)
    @system_prompt = system_prompt
    @messages = messages
    @llm = llm
  end

  def add_message(role:, content:)
    @messages << {role:, content:}
  end

  class << self
    def load_from_io(io = $stdin)
      conversations = []
      begin
        YAML.load_stream(io) do |doc|
          next unless doc
          conversations << build_from(doc)
        end
      rescue Psych::SyntaxError => e
        warn "Error: #{e.message}"
        warn "Contents:\n#{io.read}"
      end
      conversations
    end

    def load_from_file(filename)
      conversations = []
      File.open(filename, "r") do |file|
        YAML.parse_stream(file) do |doc|
          next unless doc
          conversations << build_from(doc.to_ruby)
        end
      end
      conversations
    end

    def build_from(doc)
      if doc.is_a?(Hash)
        doc = deep_symbolize_keys(doc)
      elsif doc.is_a?(String)
        doc = {messages: [{role: "user", content: doc}]}
      else
        raise ArgumentError, "Invalid document type: #{doc.class}"
      end

      system_prompt = doc[:system_prompt]
      messages = doc[:messages] || []
      convo = new(system_prompt: system_prompt, messages: messages)
      if (llm = doc[:llm])
        convo.llm = Promptcraft::Llm.from_h(llm)
      end
      convo
    end

    # Class method to create a Conversation from an array of messages
    def from_messages(messages)
      if messages.empty? || messages.first[:role] != "system"
        raise ArgumentError, "First message must be from 'system' with the prompt"
      end

      system_prompt = messages.first[:content]
      remaining_messages = messages[1..]  # all messages after the first
      new(system_prompt:, messages: remaining_messages)
    end
  end

  def save_to_file(filename)
    File.write(filename, to_yaml)
  end

  # system_prompt: 'I like to solve maths problems.'
  # messages:
  # - role: "user"
  #   content: "What is 2+2?"
  # - role: assistant
  #   content: 2 + 2 = 4
  def to_yaml
    YAML.dump(deep_stringify_keys({
      system_prompt: @system_prompt&.strip,
      llm: @llm&.to_h,
      messages: @messages
    }.compact))
  end

  def to_json
    deep_stringify_keys({
      system_prompt: @system_prompt&.strip,
      llm: @llm&.to_h,
      messages: @messages
    }.compact).to_json
  end

  def to_messages
    [{role: "system", content: @system_prompt}] + @messages
  end
end
