require 'shovel_file'
require 'shovel_directory'

class FileReader
  def initialize actions = [], start_directory = nil, started = true
    @start_directory = start_directory
    @started = started
    @actions = actions
    @error_list = []
  end

  def process_directory full_path
    Dir.chdir full_path
    puts full_path
    if full_path == @start_directory && !@started
      puts "we are starting!"
      @started = true
    end

    directories = []
    Dir.glob('*').each do |element|
      if File.directory? element
        directories << element
      elsif @started
        # execute each of the actions against the file
        context = {:file => true}
        @actions.each do |action|
          puts "About to execute action: #{action.inspect} with context: #{context.inspect} on file: #{element.inspect}"
          result = action.execute(full_path + '/' + element, context)
          if result
            if result.is_a? Array
              @error_list.concat(result)
            else
              @error_list << result
            end
          end
        end
      end
    end
    directories.each do |directory|
      # execute each of the actions against the directory
      @actions.each do |action|
        context = {:directory => true}
        puts "About to execute action: #{action.inspect} with context: #{context.inspect} on directory #{directory.inspect}"
        result = action.execute(full_path + '/' + directory, context)
        if result
          if result.is_a? Array
            @error_list.concat(result)
          else
            @error_list << result
          end
        end
      end
      @error_list.concat(process_directory(full_path + '/' + directory))
    end
    return []
  end
end