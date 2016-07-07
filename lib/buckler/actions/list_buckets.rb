module Buckler

  def self.list_buckets!

    connect_to_s3!

    verbose "Fetching buckets visible to #{@aws_access_key_id}…"
    table = [["NAME", "REGION", "VERSIONING"]]

    @s3.list_buckets.buckets.each do |bucket|
      region = @s3.get_bucket_location(bucket:bucket.name).location_constraint.presence || "us-east-1"
      versioning = @s3.get_bucket_versioning(bucket:bucket.name).status.presence || "Not Configured"
      table << [bucket.name, region, versioning]
    end

    puts_table!(table)
    exit true

  end

end
