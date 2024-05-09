# Promptcraft

An AI generated the following summary of this project for helping you to work with AI:

> Promptcraft is an innovative tool designed to optimize and test system prompts for AI-powered conversations. It allows users to replay and modify conversations using different system prompts, facilitating the development of more effective and contextually appropriate interactions with language models. Whether you're refining prompts or testing various dialogue flows, Promptcraft provides a robust environment for developers and researchers aiming to enhance the AI user experience.

Right now, there's a CLI `promptcraft` that let's to replay a conversation between a user and an AI assistant, but with a new system prompt.

```plain
$ cat examples/maths/start/already_answered.yml
system_prompt: |-
  I like to solve maths problems.

messages:
- role: "user"
  content: "What is 2+2?"
- role: assistant
  content: 2 + 2 = 4

# Let's replay the conversation with a new system prompt:
$ bundle exec exe/promptcraft \
    --conversation examples/maths/start/already_answered.yml \
    --prompt "I'm terrible at maths. If I'm asked a maths question, I reply with a question." \
    --provider groq
---
system_prompt: I'm terrible at maths. If I'm asked a maths question, I reply with
  a question.
llm:
  provider: groq
  model: llama3-70b-8192
messages:
- role: user
  content: What is 2+2?
- role: assistant
  content: What's the airspeed velocity of an unladen swallow?
```

The input `--conversation` can contain multiple YAML documents, and the output will contain multiple YAML documents.

For example, [examples/maths/start/already_answered_multiple.yml](examples/maths/start/already_answered_multiple.yml) contains two conversations:

```yaml
---
system_prompt: |-
  I like to solve maths problems.

messages:
- role: "user"
  content: "What is 2+2?"
- role: assistant
  content: 2 + 2 = 4
---
system_prompt: |-
  I like to solve maths problems.

messages:
- role: "user"
  content: "What is 6 divided by 2?"
- role: assistant
  content: 6 / 2 = 3
```

The CLI will replay each conversation with the new system prompt.

```plain
bundle exec exe/promptcraft \
    --conversation examples/maths/start/already_answered_multiple.yml \
    --prompt "I like cats. Answer any questions using cats."
```

The output shows each system prompt has been updated and the `assistant`'s response has been re-generated using the new system prompt:

```yaml
---
system_prompt: I like cats. Answer any questions using cats.
llm:
  provider: groq
  model: llama3-70b-8192
messages:
- role: user
  content: What is 2+2?
- role: assistant
  content: That's an easy one! You know how many paws a typical cat has? That's right,
    4! And if I were to divide those paws into two groups of two, I'd have... 2+2
    = 4!
---
system_prompt: I like cats. Answer any questions using cats.
llm:
  provider: groq
  model: llama3-70b-8192
messages:
- role: user
  content: What is 6 divided by 2?
- role: assistant
  content: That's an easy one! Imagine you have 6 adorable kittens, and you want to
    divide them evenly between two cat beds. How many kittens would you put in each
    bed? That's right, 3! So, 6 divided by 2 is 3.
```

The example [examples/maths/start/already_answered_multiple_providers.yml](examples/maths/start/already_answered_multiple_providers.yml) contains a conversation with the same messages, but different provider/models.

Alternately, you can pass `--conversation` option multiple times to process multiple conversation files.

```plain
bundle exec be exe/promptcraft \
    --conversation examples/maths/start/already_answered.yml \
    --conversation examples/maths/start/already_answered_gpt4.yml \
    --prompt "Answer like a pirate. A maths pirate."
```

## Installation

Right now, you need to run the CLI from the source code.

```plain
git clone https://github.com/drnic/promptcraft
cd promptcraft
bin/setup
bundle exec exe/promptcraft \
    --conversation examples/maths/start/already_answered.yml \
    --prompt "I'm terrible at maths. If I'm asked a maths question, I reply with a question." \
    --provider groq
```

It defaults to `--provider groq --model llama3-70b-8192` and assumes you have `$GROQ_API_KEY` set in your environment.

You can also use OpenAI with `--provider openai`, which defaults to `--model gpt-3.5-turbo`. It assumes you have `$OPENAI_API_KEY` set in your environment.

You can also use Ollama locally with `--provider ollama`, which defaults to `--model llama3`. It assumes your Ollama app is running on the default port.

If the conversation file has an `llm` key with `provider` and `model` keys, then those will be used instead of the defaults.

```plain
bundle exec exe/promptcraft \
    --conversation examples/maths/start/already_answered_gpt4.yml \
    --prompt "I always reply with a question"

---
system_prompt: I always reply with a question.
llm:
  provider: openai
  model: gpt-4-turbo
messages:
- role: user
  content: What is 2+2?
- role: assistant
  content: What do you think the answer is?
```

## Examples

The following example commands assume you have `$GROQ_API_KEY` and will use Groq and the `llama3-70b-8192` model as the default provider and model. You can pass `--provider openai` or `--provider ollama` to use those providers instead, and their default models.

### Getting started

Run `promptcraft` with no arguments to get a default prompt and an initial assistant message.

```plain
bundle exec exe/promptcraft
```

The output might be:

```yaml
---
system_prompt: You are helpful. If you're first, then ask a question. You like brevity.
messages:
- role: assistant
  content: What do you need help with?
```

Provide a different provider, such as `openai` (which assumes you have `$OPENAI_API_KEY` set in your environment).

```plain
bundle exec exe/promptcraft --provider openai
```

Or you could provide your own system prompt, and it will generate an initial assistant message.

```plaim
bundle exec exe/promptcraft --prompt "I like to solve maths problems."
```

The output might be:

```yaml
---
system_prompt: I like to solve maths problems.
messages:
- role: assistant
  content: |-
    A math enthusiast! I'd be happy to provide you with some math problems to solve. What level of math are you interested in? Do you want:

    1. Basic algebra (e.g., linear equations, quadratic equations)
    2. Geometry (e.g., points, lines, triangles, circles)
    3. Calculus (e.g., limits, derivatives, integrals)
    4. Number theory (e.g., prime numbers, modular arithmetic)
    5. Something else (please specify)

    Let me know, and I'll provide you with a problem to solve!
```

### Providing conversations to rechat

The primary point of `promptcraft` is to replay conversations with a new system prompt. So we need to pass them in. We have a few ways:

* Pass one or more conversation files using `--conversation` or `-c` option.
* Each conversation file can contain one or more YAML documents, each separated by `---`.
* Pass in a stream of YAML documents via STDIN.
* JSON is valid YAML, if that's ever useful to you.

An example of the `--conversation` option:

```plain
bundle exec exe/promptcraft \
    --conversation examples/maths/start/basic.yml
```

You can also pipe a stream of conversation YAML into `promptcraft` via STDIN

```plain
echo "---\nsystem_prompt: I like to solve maths problems.\nmessages:\n- role: \"user\"\n  content: \"What is 2+2?\"" | bundle exec exe/promptcraft
```

JSON is valid YAML, so you can also use JSON:

```plain
echo "{\"system_prompt\": \"I like to solve maths problems.\", \"messages\": [{\"role\": \"user\", \"content\": \"What is 2+2?\"}]}" | bundle exec exe/promptcraft
```

Or pipe one or more files into `promptcraft`:

```plain
( cat examples/maths/start/basic.yml ; cat examples/maths/start/already_answered.yml ) | bundle exec exe/promptcraft
```

As long as the input is a stream of YAML documents (separated by `---`), it will be processed.

### Creating conversation files

You could manually create these YAML files. Sure.

You could get the scaffold for the file by running `promptcraft` with no arguments, and then copy/paste the output into a new file.

Another idea is to use the Groq or ChatGPT playgrounds. Have a conversation with the AI, and then copy a screenshot into ChatGPT and ask it to convert it to YAML:

![chatgpt-vision-to-yaml](docs/images/chatgpt-vision-to-yaml.png)

That's cool.

### Missing assistant reply

If you create a conversation and the last message is from the user, then the assistant's reply is missing. The final assistant message will always be generated and added to the conversation.

For example, this basic chat only contains the user's initial message:

```yaml
system_prompt: |-
  I like to solve maths problems.

messages:
- role: "user"
  content: "What is 2+2?"
```

When we replay the conversation with the same system prompt (by omitting the `--prompt` option), it will add the missing assistant reply:

```plain
bundle exec exe/promptcraft \
    --conversation examples/maths/start/basic.yml
```

The output might be:

```yaml
---
system_prompt: I like to solve maths problems.
llm:
  provider: groq
  model: llama3-70b-8192
messages:
- role: user
  content: What is 2+2?
- role: assistant
  content: That's an easy one! The answer is... 4!
```

### Limericks

Here are some previously [generated limericks](examples/maths/start/many_limericks.yml). To regenerate them to start with letter "E" on each line:

```plain
bundle exec exe/promptcraft \
    --conversation examples/maths/start/many_limericks.yml \
    --prompt "I am excellent at limericks. I always start each line with the letter E."
```

It might still include some preamble in each response. To try to encourage the LLM to remove it:

```plain
bundle exec exe/promptcraft \
    --conversation examples/maths/start/many_limericks.yml \
    --prompt "I am excellent at limericks. I always start each line with the letter E. This is very important. Only return the limerick without any other comments."
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/promptcraft. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/promptcraft/blob/develop/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Promptcraft project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/promptcraft/blob/develop/CODE_OF_CONDUCT.md).

