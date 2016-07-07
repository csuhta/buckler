module Buckler::Logging

  def log(message)
    STDOUT.print("#{message}\n")
  end

  def alert(message)
    STDERR.print("#{message.dangerize}\n")
  end

  def verbose(message)
    STDERR.print("#{message}\n") if $buckler_verbose_mode
  end

end

module Buckler
  extend Buckler::Logging
end
