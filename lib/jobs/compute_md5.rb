class ComputeMD5
  # this method does the work, it expects a full_path to work on
  # the full_path can be a directory or a file
  def execute full_path, context
    throw ArgumentError.new("ComputeMD5 must have :directory => true or" +
        " :file => true") unless context[:directory] || context [:file]
    if context [:file]
      context[:md5_checksum] = Digest::MD5.hexdigest(File.read(full_path))
    end
  end
end