require File.expand_path(File.dirname(__FILE__) + '/init')
require 'file_reader'
require 'jobs/write_to_couch'
require 'jobs/write_to_s3'
require 'optparse'

puts "Creating database if necessary"
Lazyboy::Setup.create_databases
Lazyboy::Setup.create_indexes

puts "Starting FileReader"

write_to_couch_strategy = WriteToCouch.new
write_to_s3_strategy = WriteToS3.new
actions = [write_to_couch_strategy, write_to_s3_strategy]

# command-line arguments:
#  -t top-level directory
#  -d starting directory
top_directory = "/home/notroot/fake_dadc_disk"
start_directory = nil
opts = OptionParser.new
opts.on('-t', '--top_directory VAL', String)    { |val| top_directory = val }
opts.on('-d', '--start_directory VAL', String)    { |val| start_directory = val }
opts.parse!(ARGV)
puts "starting with top_directory = '#{top_directory}' and start_directory = '#{start_directory}'"
file_reader = FileReader.new actions, start_directory, start_directory == nil
error_list = file_reader.process_directory top_directory
puts "Done, error_list: #{error_list.inspect}"
