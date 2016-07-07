class ListRegionsTest < BucklerTest

  def test_list_regions

    stdout, stderr = run_buckler_command("regions")
    assert stdout.include?("REGION"), "Header should be printed"
    assert stdout.include?("us-west-1"), "Other rows should be printed"
    assert stdout.include?("eu-central-1"), "Other rows should be printed"
    assert stdout.include?("🇰🇷"), "Other rows should be printed"
    assert stdout.include?("China"), "Other rows should be printed"
    assert stdout.include?("Tokyo"), "Other rows should be printed"

  end

end
