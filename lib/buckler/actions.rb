module Buckler

  # Generate an Aws::S3::Bucket for the given `name`
  # Also checks that the bucket is real and we have access to it.
  # The only way to truly test bucket access is to try to read an item from it.
  # Exit with a message if there is no access.
  # Prerequisite: `Buckler.discover_aws_credentials!`

  def self.get_bucket!(name)

    unless name.present?
      alert "No bucket name provided"
      exit false
    end

    @bucket = Aws::S3::Bucket.new(name, client:@s3)

    unless @bucket.exists?
      alert "No such bucket “#{name}”"
      exit false
    end

    @bucket.objects(max_keys:1).first # Tests bucket access
    return @bucket

  rescue Aws::S3::Errors::NoSuchBucket

    alert "No such bucket “#{name}”"
    exit false

  rescue Aws::S3::Errors::AccessDenied

    alert "Access denied for bucket #{name}"
    exit false

  end

  # Prints a warning message about irreversible changes to the screen.
  # The user is required to confirm by typing the given `name_required`
  # `additional_lines` are printed before the warning.
  # If `confirmation` matches `name_required`, this method is a no-op.
  # The program ends if the confirmation is not provided.

  def self.require_confirmation!(name_required:, confirmation:nil, additional_lines:[])

    return true if confirmation == name_required

    alert "WARNING: Destructive Action"
    additional_lines.each do |line|
      log line
    end
    log "Depending on your S3 settings, this command may permanently"
    log "delete objects from the bucket #{name_required.bucketize}."
    log "To proceed, type “#{name_required}” or re-run this command with --confirm #{name_required}"
    print "> ".dangerize

    confirmation = STDIN.gets.chomp

    if confirmation == name_required
      return true
    else
      alert "Invalid confirmation “#{name_required}”, aborting"
      exit false
    end

  end

  # Prints a table neatly to the screen.
  # The given `table_array` must be an Array of Arrays of Strings.
  # Each inner array is a single row of the table, strings are cells of the row.

  def self.puts_table!(table_array)

    column_sizes = []

    table_array.first.count.times do |column_index|
      column_sizes << table_array.collect{ |row| row[column_index] }.collect(&:to_s).collect(&:length).max + 3
    end

    table_array.each do |line|
      chart_row = ""
      line.each_with_index do |column, index|
        chart_row << column.to_s.ljust(column_sizes[index])
      end
      log chart_row
    end

  end

end
