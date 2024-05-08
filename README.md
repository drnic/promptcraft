# Promptcraft

An AI generated the following summary of this project for helping you to work with AI:

> Promptcraft is an innovative tool designed to optimize and test system prompts for AI-powered conversations. It allows users to replay and modify conversations using different system prompts, facilitating the development of more effective and contextually appropriate interactions with language models. Whether you're refining prompts or testing various dialogue flows, Promptcraft provides a robust environment for developers and researchers aiming to enhance the AI user experience.

Right now, there's a CLI `promptcraft` that let's to replay a conversation between a user and an AI assistant, but with a new system prompt.

```sh
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
    --prompt <(echo "I'm terrible at maths. If I'm asked a maths question, I reply with a question.")
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

## Installation

Right now, you need to run the CLI from the source code.

```sh
git clone https://github.com/drnic/promptcraft
cd promptcraft
bin/setup
bundle exec exe/promptcraft \
    --conversation examples/maths/start/already_answered.yml \
    --prompt <(echo "I'm terrible at maths. If I'm asked a maths question, I reply with a question.")
```

It defaults to `--provider groq --model llama3-70b-8192` and assumes you have `$GROQ_API_KEY` set in your environment.

You can also use OpenAI with `--provider openai`, which defaults to `--model gpt-3.5-turbo`. It assumes you have `$OPENAI_API_KEY` set in your environment.

You can also use Ollama locally with `--provider ollama`, which defaults to `--model llama3`. It assumes your Ollama app is running on the default port.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/promptcraft. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/promptcraft/blob/develop/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Promptcraft project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/promptcraft/blob/develop/CODE_OF_CONDUCT.md).
