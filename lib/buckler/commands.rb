module Buckler::Commands; end

Buckler::Commands::Root = Cri::Command.define do

  name "bucket"
  usage "bucket <command> [options]"
  summary "peform common actions on Amazon S3 buckets"
  description %{
    Buckler allows you perform common actions on your Amazon S3 buckets.

    Run #{"bucket help <command>".bold} for more information about the commands below.

    You will need a AWS Access Key ID and AWS Secret Access Key pair with
    permission to mange your S3 buckets. Do not use your root keys.
    Generate a new set of keys with S3 permissions only.
    https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html#lock-away-credentials

    When you run the bucket command, Buckler tries to automatically
    discover AWS credentials around your working directory.

    #{"Dotenv:".bold} If the current folder has a file named .env, Buckler will look
    for variables called AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in the file.
    See Heroku’s documentation on this environment file format.
    https://devcenter.heroku.com/articles/heroku-local#set-up-your-local-environment-variables

    #{"Heroku:".bold} If the current folder has a Git repository with a Heroku remote,
    Buckler will ask your Heroku application for variables
    named AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY using heroku config:get

    #{"Command Line:".bold} You can set the pair directly by providing the
    command line options --id and --secret:

    bucket list --id YOUR_AWS_ID --secret YOUR_AWS_SECRET

    #{"Environment:".bold} You can set the pair directly as environment variables.

    AWS_ACCESS_KEY_ID=your-id AWS_SECRET_ACCESS_KEY=your-secret bucket list
  }

  flag :v, :verbose, "Output additional information for all commands"
  option nil, :id, "Your AWS Access Key ID", argument: :required
  option nil, :secret, "Your AWS Secret Access Key", argument: :required

  run do |opts, args, cmd|
    puts Buckler::Commands::Root.help
  end

end

Buckler::Commands::Version = Cri::Command.define do

  name "version"
  usage "version"
  summary "Print Buckler’s version"
  description %{
    Prints Buckler’s version number.
  }

  run do |opts, args, cmd|
    log Buckler::VERSION::STRING
  end

end

Buckler::Commands::Regions = Cri::Command.define do

  name "regions"
  usage "regions"
  summary "list all Amazon S3 regions"
  description %{
    Prints a list of all Amazon S3 bucket region names and where they are on Earth.

    When creating buckets, you should select the region that is
    closest to the users or computers that will be using the bucket.

    Heroku applications in Heroku’s America region should use Amazon region us-east-1.

    Heroku applications in Heroku’s Europe region should use Amazon region eu-west-1.
  }

  run do |opts, args, cmd|
    Buckler.list_regions!
  end

end

Buckler::Commands::List = Cri::Command.define do

  name "list"
  usage "list"
  summary "List all buckets on your account"
  description %{
    Prints a list of all Amazon S3 buckets on your account.

    “All” may be releative, AWS access keys can be generated without
    the power to see every bucket available to the master keys.
  }

  run do |opts, args, cmd|
    $buckler_verbose_mode = true if opts[:verbose].present?
    Buckler.discover_aws_credentials!(key_id:opts[:id], key:opts[:secret])
    Buckler.list_buckets!
  end

end

Buckler::Commands::Create = Cri::Command.define do

  name "create"
  usage "create <bucket-name>"
  summary "Create a new bucket"
  description %{
    Creates a new bucket on your Amazon S3 account with the given name.
    The bucket will be empty. The bucket is created in AWS region us-east-1 unless
    you specify a different region with the --region option.
    Get a list of all valid regions with `Buckler regions`.

    For maximum compatability, Amazon always recomends that you use
    DNS and TLS-safe bucket names,
    which contain only the ASCII characters a-z, 0-9, or the hypen (-)

    Bucket names with dots or uppercase letters may be unable
    to use certain Amazon Web Service features.

    Some example good bucket names:
    your-project-name,
    your-project-name-staging,
    and your-project-name-dev1

    For more information:
    http://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html
  }

  option :r, :region, "The AWS region where the bucket should be created (default: us-east-1)", argument: :required

  run do |opts, args, cmd|
    $buckler_verbose_mode = true if opts[:verbose].present?
    Buckler.discover_aws_credentials!(key_id:opts[:id], key:opts[:secret])
    Buckler.create_bucket!(name:args.first.to_s, region:opts[:region])
  end

end

Buckler::Commands::Empty = Cri::Command.define do

  name "empty"
  usage "empty <bucket-name>"
  summary "Delete all files in a bucket"
  description %{
    Discards all objects in the target bucket. The result will be an empty bucket.

    If you have not set up versioning for your bucket,
    or you have not set up Amazon Glacier backups for your bucket,
    you will be unable to recover any deleted objects.

    For more information:
    https://docs.aws.amazon.com/AmazonS3/latest/dev/delete-or-empty-bucket.html
  }

  option :c, :confirm, "Confirm destructive actions without prompting", argument: :required

  run do |opts, args, cmd|
    $buckler_verbose_mode = true if opts[:verbose].present?
    Buckler.discover_aws_credentials!(key_id:opts[:id], key:opts[:secret])
    Buckler.empty_bucket!(name:args.first.to_s, confirmation:opts[:confirm])
  end

end

Buckler::Commands::Destroy = Cri::Command.define do

  name "destroy"
  usage "destroy <bucket-name>"
  summary "Delete all files in a bucket and remove it"
  description %{
    Discards all objects in the target bucket and then removes
    the bucket from Amazon S3.

    Amazon may not immediately make the bucket name
    available for use again.

    You CANNOT delete a bucket that has versioning enabled.
    You must first disable versioning on the AWS Mangement Console.

    For more information:
    https://docs.aws.amazon.com/AmazonS3/latest/dev/delete-or-empty-bucket.html
    https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html
  }

  option :c, :confirm, "Confirm destructive actions without prompting", argument: :required

  run do |opts, args, cmd|
    $buckler_verbose_mode = true if opts[:verbose].present?
    Buckler.discover_aws_credentials!(key_id:opts[:id], key:opts[:secret])
    Buckler.destroy_bucket!(name:args.first.to_s, confirmation:opts[:confirm])
  end

end

Buckler::Commands::Sync = Cri::Command.define do

  name "sync"
  usage "sync <source-bucket> <target-bucket>"
  summary "Copy the contents of one bucket into another"
  description %{
    Copies all objects in the source bucket into the target bucket.
    Objects in the target bucket that don’t exist in the source bucket will be deleted.
    The end result will be two buckets with identical objects.

    The following properties on each object are also transfered:
    ACLs,
    Amazon S3 metadata,
    Amazon S3 storage class,
    Cache-Control header,
    Content-Type header,
    Content-Encoding header,
    Content-Disposition header,
    Content-Language header,
    and Expires header.

    The source bucket will not be changed.

    If you have not set up versioning for your bucket,
    or you have not set up Amazon Glacier archives for your bucket,
    you will be unable to recover any objects deleted from the target bucket.
  }

  option :c, :confirm, "Confirm destructive actions without prompting", argument: :required

  run do |opts, args, cmd|
    $buckler_verbose_mode = true if opts[:verbose].present?
    Buckler.discover_aws_credentials!(key_id:opts[:id], key:opts[:secret])
    Buckler.sync_buckets!(source_name:args.first.to_s, target_name:args.second.to_s, confirmation:opts[:confirm])
  end

end

Buckler::Commands::Help = Cri::Command.define do
  name "help"
  usage "buckler help"
  summary "Show help for a command"
  description "x"
  run do |opts, args, cmd|
    case args.first.to_s
    when "list"
      puts Buckler::Commands::List.help
    when "regions"
      puts Buckler::Commands::Regions.help
    when "create"
      puts Buckler::Commands::Create.help
    when "empty"
      puts Buckler::Commands::Empty.help
    when "destroy"
      puts Buckler::Commands::Destroy.help
    when "sync"
      puts Buckler::Commands::Sync.help
    else
      puts Buckler::Commands::Root.help
    end
    exit true
  end
end

Buckler::Commands::Root.add_command(Buckler::Commands::Version)
Buckler::Commands::Root.add_command(Buckler::Commands::Help)
Buckler::Commands::Root.add_command(Buckler::Commands::Regions)
Buckler::Commands::Root.add_command(Buckler::Commands::List)
Buckler::Commands::Root.add_command(Buckler::Commands::Create)
Buckler::Commands::Root.add_command(Buckler::Commands::Empty)
Buckler::Commands::Root.add_command(Buckler::Commands::Destroy)
Buckler::Commands::Root.add_command(Buckler::Commands::Sync)
