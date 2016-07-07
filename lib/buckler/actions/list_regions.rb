module Buckler

  def self.list_regions!

    table = [["REGION", "NAME", nil]]

    S3_BUCKET_REGIONS.each do |name, human_name|
      case name
      when "us-east-1"
        table << [name, human_name, "Default region"]
      when "cn-north-1"
        table << [name, human_name, "Requires Chinese account"]
      else
        table << [name, human_name, nil]
      end
    end

    puts_table!(table)
    exit true

  end

end
