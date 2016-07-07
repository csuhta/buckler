module Buckler

  def self.destroy_bucket!(name:, confirmation:nil)

    connect_to_s3!
    @bucket = get_bucket!(name)
    require_confirmation!(name_required:name, confirmation:confirmation)

    if @bucket.versioning.status == "Enabled"
      log "The bucket #{name.bucketize} has versioning enabled, it cannot be deleted."
      log "You must disable versioning in the AWS Management Console."
      exit false
    end

    log "Destroying bucket #{name.bucketize}…"
    @bucket.delete!(max_attempts:3)
    log "Bucket #{name.bucketize} was destroyed ✔"
    exit true

  end

end
