require "yaml"

class Promptcraft::Conversation
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
    def load_from_file(filename)
      conversations = []
      File.open(filename, "r") do |file|
        YAML.parse_stream(file) do |doc|
          doc = deep_symbolize_keys(doc.to_ruby)
          system_prompt = doc[:system_prompt]
          messages = doc[:messages]
          convo = new(system_prompt: system_prompt, messages: messages)
          if (llm = doc[:llm])
            convo.llm = Promptcraft::Llm.from_h(llm)
          end
          conversations << convo
        end
      end
      conversations
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

    def deep_symbolize_keys(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, v), result|
          result[key.to_sym] = deep_symbolize_keys(v)  # Convert keys to symbols and recursively handle values
        end
      when Array
        value.map { |v| deep_symbolize_keys(v) }  # Apply symbolization to each element in the array
      else
        value  # Return the value as is if it is neither a hash nor an array
      end
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

  def deep_stringify_keys(value)
    case value
    when Hash
      value.map { |k, v| [k.to_s, deep_stringify_keys(v)] }.to_h
    when Array
      value.map { |v| deep_stringify_keys(v) }
    else
      value
    end
  end
end
