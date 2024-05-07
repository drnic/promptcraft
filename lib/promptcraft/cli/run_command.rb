require "tty-option"

class Promptcraft::Cli::RunCommand
  include TTY::Option

  usage do
    program "promptcraft"

    command "run"

    desc "Re-run conversation against new system prompt"
  end

  option :directory do
    required
    short "-d"
    long "--dir path"
    desc "Directory for prompt and conversation files"
  end

  flag :help do
    short "-h"
    long "--help"
    desc "Print usage"
  end

  def run
    if params[:help]
      print help
    elsif params.errors.any?
      puts params.errors.summary
    else
      pp params.to_h
      # It will find latest iteration
      # It will check if latest iteration is complete or not
      # If it is not complete, it will continue from where it left
    end
  end
end
