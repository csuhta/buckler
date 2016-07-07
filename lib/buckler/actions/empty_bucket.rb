module Buckler

  def self.empty_bucket!(name:, confirmation:nil)

    connect_to_s3!
    @bucket = get_bucket!(name)
    require_confirmation!(name_required:name, confirmation:confirmation)

    log "Deleting all objects in bucket #{name.bucketize}…"
    @bucket.clear!
    log "Bucket #{name.bucketize} is now empty ✔"
    exit true

  end

end
