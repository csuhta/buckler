class CreateBucketTest < BucklerTest

  def test_create_bucket

    test_name = "buckler-#{SecureRandom.hex(6)}"
    bucket = Aws::S3::Bucket.new(test_name, client:@s3)

    # Test that a bucket was indeed created

    stdout, stderr = run_buckler_command("create #{test_name}")
    assert stdout.include?("available for use"), "“availble for use” text should be printed"
    assert stdout.include?(test_name), "Bucket name should be repeated to user"
    assert bucket.exists?, "Bucket should be created"

    # Can’t create a bucket that already exisits

    stdout, stderr = run_buckler_command("create #{test_name}")
    assert stderr.include?("already exists"), "“already exists” text not printed"
    assert stderr.include?(test_name), "Bucket name not repeated to user"

    # Cleanup

    bucket.delete! if bucket.exists?

  end

end
