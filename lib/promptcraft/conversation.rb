require "yaml"

class Promptcraft::Conversation
  attr_accessor :system_prompt, :messages

  def initialize(system_prompt = "")
    @system_prompt = system_prompt
    @messages = []
  end

  def add_message(role, content)
    @messages << {role: role, content: content}
  end

  def load_from_file(filename)
    data = YAML.load_file(filename)
    @system_prompt = data["system_prompt"]
    @messages = data["messages"]
  end

  def save_to_file(filename)
    File.write(filename, to_yaml)
  end

  def to_yaml
    YAML.dump({
      "system_prompt" => @system_prompt,
      "messages" => @messages
    })
  end

  def to_messages
    [{role: "system", content: @system_prompt}] + @messages
  end

  # Class method to create a Conversation from an array of messages
  def self.from_messages(messages)
    if messages.empty? || messages.first[:role] != "system"
      raise ArgumentError, "First message must be from 'system' with the prompt"
    end

    system_prompt = messages.first[:content]
    remaining_messages = messages[1..]  # all messages after the first
    conversation = new(system_prompt)
    remaining_messages.each do |message|
      conversation.add_message(message[:role], message[:content])
    end
    conversation
  end
end
