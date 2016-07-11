class SyncBucketsTest < BucklerTest

  def test_sync_buckets

    # Fill a bucket and sync it

    source_bucket, source_name = create_test_bucket
    target_bucket, target_name = create_test_bucket
    load_bucket_with_objects(source_bucket)

    stdout, stderr = run_buckler_command("sync #{source_name} #{target_name} --confirm #{target_name}")
    assert target_bucket.objects.to_a.many?, "The target bucket should be filled with goodies"
    assert target_bucket.objects.to_a.count.eql?(50), "The target bucket should be filled with goodies"
    assert target_bucket.objects.first.object.content_type.include?("text/plain"), "Content-Type headers should have synced"
    assert target_bucket.objects.first.object.cache_control.include?("no-cache"), "Cache-Control headers should have synced"

    # Can’t sync bad buckets

    bad_name = "bucker-#{SecureRandom.hex(6)}"
    stdout, stderr = run_buckler_command("sync #{source_name} #{bad_name} --confirm #{bad_name}")
    assert stderr.include?("No such bucket"), "“No such” message should be printed"
    assert stderr.include?(bad_name), "Bucket name should be repeated"

    # Cleanup

    source_bucket.delete! if source_bucket.exists?
    target_bucket.delete! if target_bucket.exists?

  end

end
