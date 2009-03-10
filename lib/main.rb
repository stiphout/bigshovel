require File.expand_path(File.dirname(__FILE__) + '/init')
require 'file_reader'
require 'optparse'

puts "Creating database if necessary"
Lazyboy::Setup.create_databases
Lazyboy::Setup.create_indexes

puts "Starting FileReader"

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
file_reader = FileReader.new start_directory, start_directory == nil
file_reader.process_directory top_directory
