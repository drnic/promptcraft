require "yaml"

class Promptcraft::Conversation
  attr_accessor :system_prompt, :messages

  def initialize(system_prompt:, messages: [])
    @system_prompt = system_prompt
    @messages = messages
  end

  def add_message(role:, content:)
    @messages << {role:, content:}
  end

  class << self
    def load_from_file(filename)
      data = YAML.load_file(filename, symbolize_names: true)
      new(system_prompt: data[:system_prompt], messages: data[:messages])
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
      system_prompt: @system_prompt,
      messages: @messages
    }.compact))
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
