class DestroyBucketTest < BucklerTest

  def test_destroy_bucket

    bucket, test_name = create_test_bucket

    # Test that a bucket was indeed destroyed

    stdout, stderr = run_buckler_command("destroy #{test_name} --confirm #{test_name}")
    assert stdout.include?("destroyed"), "Destruction confirmation should be printed"
    assert stdout.include?(test_name), "Bucket name should be repeated"

    # Can’t destroy a bucket that doesn’t exist

    stdout, stderr = run_buckler_command("destroy #{test_name}")
    assert stderr.include?("No such bucket"), "Rejection message should be printed"
    assert stderr.include?(test_name), "Bucket name should be repeated to user"

  end

end
