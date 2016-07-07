class BucklerTest < Minitest::Test

  # An S3 client for checking/cleaning the results of actions
  # that the bucket executable should have performed

  def initialize(*args)
    @s3 = Aws::S3::Client.new(
      region: "us-east-1",
      access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
    )
    super
  end

  # Create a test bucket and return it

  def create_test_bucket
    test_name = "buckler-#{SecureRandom.hex(6)}"
    bucket = Aws::S3::Bucket.new(test_name, client:@s3)
    bucket.create
    bucket.wait_until_exists
    return [bucket, test_name]
  end

  # Fills a bucket with random, but testable objects
  
  def load_bucket_with_objects(bucket)
    50.times do
      bucket.put_object({
        acl: "private",
        body: SecureRandom.hex,
        key: "#{SecureRandom.uuid}.txt",
        content_type: "text/plain",
        cache_control: "no-cache",
      })
    end
    fail unless bucket.objects.to_a.many?
    return true
  end

  # Runs the given buckler `command`
  # Returns two values: the text that the process printed to STDOUT
  # and the text the process printed to STDERR

  def run_buckler_command(command)

    command_stdout_ouput, command_stdout_intake = IO.pipe
    command_stderr_ouput, command_stderr_intake = IO.pipe

    environment = {
      "AWS_ACCESS_KEY_ID" => ENV.fetch("AWS_ACCESS_KEY_ID"),
      "AWS_SECRET_ACCESS_KEY" => ENV.fetch("AWS_SECRET_ACCESS_KEY"),
    }

    pid = Kernel.spawn(
      environment,
      "#{BUCKLER_EXECUTABLE} #{command}",
      STDOUT => command_stdout_intake,
      STDERR => command_stderr_intake,
    )

    command_stdout_intake.close
    command_stderr_intake.close

    Process.wait2(pid)

    stdout_results = command_stdout_ouput.read
    stderr_results = command_stderr_ouput.read

    command_stdout_ouput.close
    command_stderr_ouput.close

    return [
      stdout_results,
      stderr_results
    ]

  end

end
