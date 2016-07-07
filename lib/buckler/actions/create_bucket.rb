module Buckler

  def self.create_bucket!(name:nil, region:nil)

    unless name.present?
      alert "No bucket name provided."
      alert "Usage: bucket create <bucket-name> --region <region>"
      exit false
    end

    region ||= "us-east-1"
    unless valid_region?(region)
      log "Invalid region “#{region}”"
      log "Use `bucket regions` to see a list of all S3 regions"
      exit false
    end

    connect_to_s3!(region:region)
    @bucket = Aws::S3::Bucket.new(name, client:@s3)

    if @bucket.exists?
      alert "Bucket #{@bucket.name} already exists"
      exit false
    end

    log "Creating bucket #{name.bucketize} on #{region}…"

    options = {
      acl: "private"
    }

    unless region.eql?("us-east-1")
      options[:create_bucket_configuration] = {
        location_constraint: region
      }
    end

    @bucket.create(options)
    @bucket.wait_until_exists

    log "Bucket #{name.bucketize} is how available for use ✔"
    exit true

  rescue Aws::S3::Errors::BucketAlreadyExists

    alert "The bucket name “#{name}” is already taken."
    alert "Bucket names must be unique across the entire AWS ecosystem."
    alert "Select a different bucket name and re-run your command."
    exit false

  end

end
