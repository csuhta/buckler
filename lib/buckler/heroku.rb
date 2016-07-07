module Buckler

  # Returns the Ruby executable on the user’s $PATH
  def self.ruby_cmd
    @ruby_cmd ||= find_executable0("ruby")
  end

  # Returns the Heroku executable on the user’s $PATH
  def self.heroku_cmd
    @heroku_cmd ||= find_executable0("heroku")
  end

  # True if the user has a Heroku and Ruby executable
  def self.heroku_available?
    ruby_cmd.present? && heroku_cmd.present?
  end

  # Fetches the given environment `variable_name` from the user’s Heroku project
  def self.heroku_config_get(variable_name)

    command_output, command_intake = IO.pipe

    pid = Kernel.spawn(
      "#{ruby_cmd} #{heroku_cmd} config:get #{variable_name}",
      STDOUT => command_intake,
      STDERR => command_intake
    )

    command_intake.close

    _, status = Process.wait2(pid)

    if status.exitstatus == 0
      results = command_output.read.to_s.chomp
      verbose %{`heroku config:get #{variable_name}` returned "#{results}"}
      return results
    else
      verbose %{`heroku config:get #{variable_name}` returned a nonzero exit status}
      return false
    end

  end

end
