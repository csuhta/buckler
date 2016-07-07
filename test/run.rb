require "securerandom"
require "dotenv"
require "aws-sdk"
require "active_support/core_ext/object"
require "active_support/core_ext/string"
require "active_support/core_ext/array"
require "active_support/core_ext/enumerable"

require "minitest"
require "minitest/pride"
require "minitest/autorun"

# Filter out Minitest backtrace while allowing backtrace from
# other libraries to be shown
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load AWS credentials from a .env file in this directory
Dotenv.load

require "#{BUCKLER_ROOT}/test/buckler_test"
Dir["#{BUCKLER_ROOT}/test/integration/*.rb"].each do |test_file|
  require test_file
end
