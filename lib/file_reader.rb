require 'shovel_file'
require 'shovel_directory'

class FileReader
  def initialize start_directory = nil, started = true
    @start_directory = start_directory
    @started = started
  end

  def create_shovel_file full_path
    if !File.exists?(full_path)
      puts "\nFile with full_path #{full_path} does not exist."
      return nil
    end
    shovel_file = ShovelFile.new
    shovel_file.original_full_path = full_path
    shovel_file.original_path = File.split(full_path)[0]
    shovel_file.original_file_name = File.split(full_path)[1]
    shovel_file.file_size = File.size(full_path)
    shovel_file.icpn = find_icpn full_path
    shovel_file.md5_checksum = Digest::MD5.hexdigest(File.read(full_path))
    return shovel_file
  end

  def create_shovel_directory full_path
    shovel_directory = ShovelDirectory.new
    shovel_directory.original_full_path = full_path
    file_count = 0
    Dir.glob('*').each do |element|
      if !File.directory? element
        file_count = file_count + 1
      end
    end
    shovel_directory.file_count = file_count
    shovel_directory.icpn = find_icpn full_path
    return shovel_directory
  end

  def find_icpn full_path
    if File.directory? full_path
      directory = full_path.split('/')[-1]
    else
      directory = full_path.split('/')[-2]
    end

    if directory.length == 13 && directory =~ /^[0-9]*$/
      return directory
    end
    return nil
  end

  def process_directory full_path
    Dir.chdir full_path
    puts full_path
    if full_path == @start_directory && !@started
      puts "we are starting!"
      @started = true
    end
    shovel_directory = find_shovel_directory full_path
    if !shovel_directory
      shovel_directory = create_shovel_directory full_path
      shovel_directory.save
    end

    directories = []
    Dir.glob('*').each do |element|
      if File.directory? element
        directories << element
      elsif @started
        process_file full_path + '/' + element
      end
    end
    directories.each do |directory|
      process_directory full_path + '/' + directory
    end
  end

  def process_file full_path
    # is there already a record for this in Couch?
    shovel_file = find_shovel_file full_path
    if !shovel_file
      shovel_file = create_shovel_file full_path
      shovel_file.save
    else
      puts "Ignoring file as it already exists in Couch."
    end
  end

   def find_shovel_directory full_path
    shovel_directories = ShovelDirectory.find_by_original_full_path :all, full_path
    return shovel_directories[0] if shovel_directories.length == 1
    return nil
  end

  def find_shovel_file full_path
    shovel_files = ShovelFile.find_by_original_full_path :all, full_path
    return shovel_files[0] if shovel_files.length == 1
    return nil
  end
end