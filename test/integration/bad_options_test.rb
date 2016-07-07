class BadOptionsTest < BucklerTest

  def test_bad_credentials

    # Errors about bad credentials
    stdout, stderr = run_buckler_command("list --id CUTE_CATS --secret BUT_ALSO_DOGGIES")
    assert stderr.include?("Invalid AWS Access Key"), "Error message should be printed"
    assert stderr.include?("CUTE_CATS"), "Should repeat Key ID"

    # Errors when the ID is correct but the secret is wrong
    stdout, stderr = run_buckler_command("list --id #{ENV.fetch("AWS_ACCESS_KEY_ID")} --secret BUT_ALSO_DOGGIES")
    assert stderr.include?("Invalid AWS Secret Access Key"), "Error message should be printed"
    assert stderr.include?(ENV.fetch("AWS_ACCESS_KEY_ID")), "Should repeat Key ID"

  end

  def test_invaid_options

    # Passing invalid options should not work
    stdout, stderr = run_buckler_command("list --fake FAKE --uhh")
    assert stderr.include?("illegal option"), "Error message should be printed"

  end

end
