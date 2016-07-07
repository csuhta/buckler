$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "buckler/version"

Gem::Specification.new do |s|

  s.name          = "buckler"
  s.version       = Buckler::VERSION::STRING
  s.platform      = Gem::Platform::RUBY
  s.licenses      = ["MIT"]
  s.authors       = ["Corey Csuhta"]
  s.homepage      = "https://github.com/csuhta/buckler"
  s.summary       = "Perform common actions on S3 buckets from the command line"
  s.description   = "Buckler is a Ruby command line tool for performing common actions on Amazon S3 buckets. It’s more do-what-you-want and less overwhelmingly powerful than the AWS CLI. It’s also designed to work with Heroku applications."

  s.executables   = ["bucket"]
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files --directory test`.split("\n")
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.2.3"

  s.add_dependency "activesupport", "~> 5.0"
  s.add_dependency "aws-sdk", "~> 2.0"
  s.add_dependency "dotenv", "~> 2.1"
  s.add_dependency "cri", "~> 2.7"

  s.add_development_dependency "rake", "~> 11.2"
  s.add_development_dependency "minitest", "~> 5.7"
  s.add_development_dependency "yard", "~> 0.6"

end
