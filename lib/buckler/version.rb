module Buckler

  # Returns Buckler’s version number
  def self.version
    Gem::Version.new("1.0.2")
  end

  # Contains Buckler’s version number
  module VERSION
    MAJOR, MINOR, TINY, PRE = Buckler.version.segments
    STRING = Buckler.version.to_s
  end

end
