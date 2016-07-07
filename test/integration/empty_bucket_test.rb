class EmptyBucketTest < BucklerTest

  def test_empty_bucket

    # Fill a bucket and empty it

    bucket, test_name = create_test_bucket
    load_bucket_with_objects(bucket)
    stdout, stderr = run_buckler_command("empty #{test_name} --confirm #{test_name}")
    assert bucket.objects.none?, "The bucket should be emptied"

    # Can’t empty a nonexistent bucket

    test_name = "buckler-#{SecureRandom.hex(6)}"
    stdout, stderr = run_buckler_command("empty #{test_name}")
    assert stderr.include?("No such"), "Error message should be printed"
    assert stderr.include?(test_name), "Bucket name should be repeated"

    # Cleanup

    bucket.delete! if bucket.exists?

  end

end
