module Buckler

  # Returns the discovered AWS Access Key ID
  # Prerequisite: `Buckler.discover_aws_credentials!`
  def self.aws_access_key_id
    @aws_access_key_id
  end

  # Returns an Aws::S3::Client in the given `region`
  # Prerequisite: `Buckler.discover_aws_credentials!`
  def self.connect_to_s3!(region:"us-east-1")
    return @s3 if @s3.present?
    @s3 = Aws::S3::Client.new(
      region: region,
      access_key_id: @aws_access_key_id,
      secret_access_key: @aws_secret_access_key,
    )
    return @s3
  end

  # Attempts to find the AWS Access Key ID and Secret Access Key
  # by searching the command line paramters, the environment, the .env, and Heroku in that order.
  # The parameters are the values of --id and --secret on the command line.
  # The program ends if credentials cannot be discovered.
  def self.discover_aws_credentials!(key_id:nil, key:nil)

    verbose "Attempting to find AWS credentials…"

    # Try to find keys as command line parameters, if the invoker has set them directly
    if key_id.present? && key.present?
      verbose "The Access Key ID and Secret Access Key were set as command line options ✔"
      @aws_access_key_id = key_id
      @aws_secret_access_key = key
      return true
    end

    # Try to find keys in the current environment, if the invoker has set them directly
    key_id = ENV["AWS_ACCESS_KEY_ID"]
    key = ENV["AWS_SECRET_ACCESS_KEY"]
    if key_id.present? && key.present?
      verbose "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY found as environment variables ✔"
      @aws_access_key_id = key_id
      @aws_secret_access_key = key
      return true
    end

    # Try to find keys in a .env file in this directory
    Dotenv.load
    key_id = ENV["AWS_ACCESS_KEY_ID"]
    key = ENV["AWS_SECRET_ACCESS_KEY"]
    if key_id.present? && key.present?
      verbose "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY found in the .env file ✔"
      @aws_access_key_id = key_id
      @aws_secret_access_key = key
      return true
    end

    # Try to find keys by asking Heroku about the project in this directory
    if heroku_available?
      key_id = heroku_config_get("AWS_ACCESS_KEY_ID")
      key = heroku_config_get("AWS_SECRET_ACCESS_KEY")
      if key_id.present? && key.present?
        verbose "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY found on your Heroku application ✔"
        @aws_access_key_id = key_id
        @aws_secret_access_key = key
        return true
      end
    end

    alert "Could not discover any AWS credentials."
    alert "Set command line options --id and --secret"
    alert "Or, set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY as environment variables."
    alert "Or, set them in a .env file in this directory."
    if heroku_available?
      alert "Or, set them on a Heroku application in this directory with `heroku config:set`."
    end
    exit false

  end

end
