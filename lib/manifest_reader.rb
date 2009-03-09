require 'init'
require 'models/manifest_item'

puts "Hello World "  + Time.new.to_s

Lazyboy::Setup.destroy_databases rescue nil
Lazyboy::Setup.create_databases
Lazyboy::Setup.create_indexes

@write_to_file = false
@write_to_db = true

@count = 0
@files = []

Dir.foreach('../data') do |file_name|
  @files << file_name if file_name.match(/Fullcat/i) and not file_name.match(/json/i)
end

@files = @files.sort { |a,b|  a.downcase <=> b.downcase}

@files.each do |file|
  puts 'Processing => ' + file
  @item_hash = {}
  @output = File.new('../data/' + file + '.json', 'w')
  IO.foreach('../data/' + file) do |line|
    # Remove any preceding whitespace..
    line.strip!

    unless line.empty?
      # Creates an array of four items for each of the lines above...
      @item = line.split(' ')

      if line.match(/Datentr/)
        # Header detail... disk name
        # Datentr"ger in Laufwerk N: ist Fullcat_HD01_Data
        @disk_name = @item[5]

      elsif @item[0] == 'Volumeseriennummer:'
        # Header detail... serial number
        # Volumeseriennummer: 448A-F5FB
        @disk_seriel_number = @item[1]

      elsif line.match(/Anzahl der angezeigten Dateien:/)
        # Footer detail...
        # Anzahl der angezeigten Dateien:
        # Ignore

      elsif @item[1] == 'Verzeichnis(se),'
        # Footer detail... total size
        # Verzeichnis(en)
        @total_disk_items = @item[0]
        @total_disk_size = @item[2]
        begin
          ManifestItem.create(:manifest_item => {:type => 'Disk',
            :name => @disk_name,
            :serial_number => @disk_seriel_number,
            :items => @total_disk_items.gsub('.', ''),
            :size => @total_disk_size.gsub('.', '')}) if @write_to_db
        rescue Error => bang
          puts bang
        end
        @output.write("{'Type':'Disk', 'Name':'" + @disk_name +
          "', 'SerialNumber':'" + @disk_seriel_number +
          "', 'Items':" + @total_disk_items +
          ", 'Size':" + @total_disk_size + "}" + "\n") if @write_to_file

      elsif @item[0] == 'Verzeichnis'
        # Indicates the start of a new 'section' contents...
        #  Verzeichnis von N:\
        #  Verzeichnis von N:\fullcat_Audio_20080807180534_HDD
        @path = line.split(' ')[2]
        @folder_name = @path.split("\\")[@path.split("\\").length - 1]
        @folder_name = '<root>' if @folder_name.nil?

      elsif @item[1] == 'Datei(en)'
        # Indicates the end of a 'section'...
        # 0 Datei(en)              0 Bytes
        # 2 Datei(en)          8.346 Bytes
        @folder_items = @item[0]
        @folder_size = @item[2]
        details = @item_hash[@folder_name]
        begin
          ManifestItem.create(:manifest_item => {:type => 'Folder',
            :name => @folder_name,
            :path => @path,
            :date => (details ? details[:date] : ''),
            :name => (details ? details[:time] : ''),
            :items => @folder_items.gsub('.', ''),
            :size => @folder_size.gsub('.', '')}) if @write_to_db
        rescue Error => bang
          puts bang
        end
        @output.write("{'Type':'Folder', 'Path':'" + @path +
          "', 'Name':'" + @folder_name +
          "', 'Date':'" + (details ? details[:date] : '') +
          "', 'Time':'" + (details ? details[:time] : '') +
          "', 'Items':" + @folder_items +
          ", 'Size':" + @folder_size + '}' + "\n") if @write_to_file

      elsif @item[2] == '<DIR>' and (@item[3] == '.' or @item[3] == '..')
        # Ignore these at the beginning of each section...
        # 12.08.2008  07:36    <DIR>          .
        # 12.08.2008  07:36    <DIR>          ..

      elsif @item[2] == '<DIR>'
        # Indicates a root folder definition
        # 12.08.2008  07:36    <DIR> fullcat_Audio_20080807180534_HDD
        # Indicates a product folder definition...
        # 12.08.2008  07:21    <DIR>          0015707984256

        @item_hash[@item[3]] = {:name => @item[3], :date => @item[0], :time => @item[1], :type => 'Folder'}

      elsif @item.length > 3 and
        (@item[3].match(/(.txt)\z/) or
         @item[3].match(/(.wav)\z/) or
         @item[3].match(/(.log)\z/) or
         @item[3].match(/(.copy)\z/) or
         @item[3].match(/(.xml)\z/))

        # Indicates a file definition...
        # 09.08.2008  00:47             6.578 fullcat_Audio_20080807180534_HDD_upc_data.txt

        begin
          ManifestItem.create(:manifest_item => {:type => 'File',
            :name => @item[3],
            :path => @path + '\\' + @item[3],
            :date => @item[0],
            :name => @item[1],
          :size => @item[2].gsub('.', '')}) if @write_to_db
        rescue Error => bang
          puts bang
        end
        @output.write("{'Type':'File', 'Path':'" + @path + '\\' + @item[3] +
          "', 'Name':'" + @item[3] +
          "', 'Date':'" + @item[0] +
          "', 'Time':'" + @item[1] +
          ", 'Size':" + @item[2] + '}' + "\n") if @write_to_file

      else
        @output.write("{'Type':'Error', 'Detail':'" + line + "'}"+ "\n") if @write_to_file
        puts 'Cant process => ' + line
      end
    end
  end
  @output.close
end

puts "Goodbye World"  + Time.new.to_s
