class ListBucketsTest < BucklerTest

  def test_list_buckets

    bucket, test_name = create_test_bucket

    # Test that a bucket is listed

    stdout, stderr = run_buckler_command("list")
    assert stdout.include?(test_name), "Bucket name should be repeated"
    assert stdout.include?("us-east-1"), "Bucket region should be repeated"
    assert stdout.include?("NAME"), "Header should be printed"

    # Cleanup

    bucket.delete! if bucket.exists?

  end

end
