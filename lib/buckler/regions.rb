module Buckler

  S3_BUCKET_REGIONS = {
    "us-east-1"      => "🇺🇸  US East (Virginia)",
    "us-west-1"      => "🇺🇸  US West (California)",
    "us-west-2"      => "🇺🇸  US West (Oregon)",
    "sa-east-1"      => "🇧🇷  South America (São Paulo)",
    "eu-central-1"   => "🇩🇪  Europe (Frankfurt)",
    "eu-west-1"      => "🇮🇪  Europe (Ireland)",
    "ap-northeast-1" => "🇯🇵  Asia Pacific (Tokyo)",
    "ap-northeast-2" => "🇰🇷  Asia Pacific (Seoul)",
    "ap-south-1"     => "🇮🇳  Asia Pacific (Mumbai)",
    "ap-southeast-1" => "🇸🇬  Asia Pacific (Singapore)",
    "ap-southeast-2" => "🇦🇺  Asia Pacific (Sydney)",
    "cn-north-1"     => "🇨🇳  China (Beijing)",
  }.freeze

  # True if the given name is a valid AWS region.
  def self.valid_region?(name)
    S3_BUCKET_REGIONS.keys.include?(name)
  end

end
