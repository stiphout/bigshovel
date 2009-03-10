class WriteToS3
  # this method does the work, it expects a full_path to work on
  # the full_path can be a directory or a file
  def execute full_path, context = {}
    throw ArgumentError.new("WriteToS3 must have :directory => true or" +
        " :file => true") unless context[:directory] || context [:file]
    throw ArgumentError.new("WriteToS3 must have a :shovel_file if" +
        " :file => true") if context[:file] && !context[:shovel_file]
    if context [:file] && context[:shovel_file]
      shovel_file = context[:shovel_file]
      s3_storage_key = create_key_string(shovel_file)
      mime_type = guess_mime_type(shovel_file.original_file_name)
      s3_headers = { 'content-type' => mime_type, 'content-disposition' => "attachment; filename=\"#{shovel_file.original_file_name}\"" }
      shovel_file.s3_key = s3_storage_key
      shovel_file.save
      s3ok = write_file_to_s3 s3_storage_key, File.open(full_path), s3_headers
      return [] if s3ok
      return ["Failed to write file with path: #{full_path}, shovel_file: #{shovel_file.inspect} to S3"]
    end
  end

  # Creates a key of the form YYYY/MM/DD/U
  def create_key_string shovel_file
    time_dir = Time.now.utc.strftime('%Y/%m/%d/')
    return time_dir + "#{shovel_file.id}"
  end

  # Writes a file to s3
  def write_file_to_s3 entity_key, io_obj,
    s3_headers = { 'content-type' => 'application/octet-stream'}

    con = RightAws::S3Interface.new(
      EMI_CONFIG[:global][:aws_access_key_id],
      EMI_CONFIG[:global][:aws_secret_access_key],
      {:multi_thread => false})
    bucket = EMI_CONFIG[:asset][:default_bucket]

    con.put(bucket, entity_key, io_obj, s3_headers)
  end

  def guess_mime_type(filename)
    matches = filename.match(/\.(\w+)$/)
    case matches ? matches[1].downcase : nil
    when 'wav'   then 'audio/x-wav'
    when 'wma'   then 'audio/x-ms-wma'
    when 'mp3'   then 'audio/mpeg'
    when /tiff?/ then 'image/tiff'
    when 'png'   then 'image/png'
    when 'jpg'   then 'image/jpeg'
    when 'jpeg'   then 'image/jpeg'
    else 'application/octet-stream'
    end
  end
end