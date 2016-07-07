module Buckler

  def self.sync_buckets!(source_name:, target_name:, confirmation:nil)

    unless source_name.present? && target_name.present?
      alert "You must provide both a source bucket and a target bucket"
      alert "Usage: bucket sync <source-bucket> <target-bucket>"
      exit false
    end

    unless source_name != target_name
      alert "The source bucket name and target bucket name must be different"
      exit false
    end

    connect_to_s3!
    @source_bucket = get_bucket!(source_name)
    @target_bucket = get_bucket!(target_name)

    source_name = @source_bucket.name.bucketize(:pink).freeze
    target_name = @target_bucket.name.bucketize.freeze

    require_confirmation!(name_required:@target_bucket.name, confirmation:confirmation, additional_lines:[
      "The contents of #{source_name} will be synced into #{target_name}.",
      "Objects in #{target_name} that aren’t in the source bucket will be removed.",
    ])

    log "Syncing #{source_name} into #{target_name}…"
    log "Fetching bucket file lists…"

    @source_bucket_keys = @source_bucket.objects.collect(&:key)
    @target_bucket_keys = @target_bucket.objects.collect(&:key)

    # -------------------------------------------------------------------------
    # Delete bucket differences
    # -------------------------------------------------------------------------

    @keys_to_delete = @target_bucket_keys - @source_bucket_keys

    @dispatch = Buckler::ThreadDispatch.new

    log "Deleting unshared objects from target bucket…"

    @keys_to_delete.lazy.each do |key|
      @dispatch.queue(lambda {
        log "Deleting #{target_name}/#{key}"
        @target_bucket.object(key).delete
      })
    end

    time_elapsed = @dispatch.perform_and_wait
    log "Unshared objects deleted from target bucket (#{time_elapsed} seconds) ✔"

    # -------------------------------------------------------------------------
    # Sync files
    # -------------------------------------------------------------------------

    @dispatch = Buckler::ThreadDispatch.new

    @source_bucket_keys.lazy.each do |object_key|

      @dispatch.queue(lambda {

        source_object = Aws::S3::Object.new(@source_bucket.name, object_key, client:@s3)
        target_object = Aws::S3::Object.new(@target_bucket.name, object_key, client:@s3)

        options = {
          storage_class: source_object.storage_class,
          metadata: source_object.metadata,
          content_encoding: source_object.content_encoding,
          content_language: source_object.content_language,
          content_type: source_object.content_type,
          cache_control: source_object.cache_control,
          expires: source_object.expires,
        }

        if source_object.content_disposition.present?
          options[:content_disposition] = ActiveSupport::Inflector.transliterate(source_object.content_disposition, "")
        end

        if source_object.content_length > 5242882 # 5 megabytes + 2 bytes
          options[:multipart_copy] = true
          options[:content_length] = source_object.content_length
        end

        target_object.copy_from(source_object, options)
        target_object.acl.put({
          access_control_policy: {
            grants: source_object.acl.grants,
            owner: source_object.acl.owner,
          }
        })

        log "Copied #{source_name} → #{target_name}/#{object_key}"

      })

    end

    time_elapsed = @dispatch.perform_and_wait
    log "#{@source_bucket_keys.count} objects synced in #{target_name} (#{time_elapsed} seconds) ✔"
    exit true

  end

end
