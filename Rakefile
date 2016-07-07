BUCKLER_ROOT = File.dirname(__FILE__)
BUCKLER_EXECUTABLE = "#{BUCKLER_ROOT}/bin/bucket"

desc "Open an irb session preloaded with this library"
task :console do
  exec "irb -rubygems -I lib -r buckler.rb"
end

desc "Run Buckler’s test suite"
task :test do
  require "./test/run"
end

# Creates the build/install/release tasks
require "bundler/setup"
Bundler::GemHelper.install_tasks
