puts "\n===== Shovel Spec ====="

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'lazyboy'
require 'file_reader'

# The spec tests that we can look at a file and create the corresponding
# Lazyboy model object



describe FileReader do

  before(:all) do
    Lazyboy::Setup.destroy_databases rescue nil
    Lazyboy::Setup.create_databases
    Lazyboy::Setup.create_indexes
  end

  it "should return nil when getting details for a file that does not exist" do
    full_path = "/test/test.wav"
    File.should_receive(:exists?).with(full_path).and_return(false)
    file_reader = FileReader.new
    result = file_reader.create_shovel_file full_path
    result.should eql(nil)
  end

  it "should return a ShovelFile Lazyboy model when getting details for a file that does exist" do
    full_path = "/test/test.wav"
    File.should_receive(:exists?).with(full_path).and_return(true)
    File.should_receive(:split).with(full_path).at_least(1).and_return(['/test', 'test.wav'])
    File.should_receive(:size).with(full_path).and_return(123)
    file_reader = FileReader.new
    result = file_reader.create_shovel_file full_path
    result.should_not eql(nil)
    result.original_file_name.should eql('test.wav')
    result.original_path.should eql('/test')
    result.original_full_path.should eql(full_path)
    result.file_size.should eql(123)
  end

  it "should find an icpn for a directory" do
    full_path = '/test/1234567890123/'
    File.should_receive(:directory?).with(full_path).and_return(true)
    file_reader = FileReader.new
    icpn = file_reader.find_icpn full_path
    icpn.should eql('1234567890123')
  end

  it "should find an icpn for a file" do
    full_path = '/test/1234567890123/1234567890123_01_001.xml'
    File.should_receive(:directory?).with(full_path).and_return(false)
    file_reader = FileReader.new
    icpn = file_reader.find_icpn full_path
    icpn.should eql('1234567890123')
  end

  it "should not find an icpn with non-numeric characters" do
    full_path = '/test/1234567890ab3/'
    file_reader = FileReader.new
    icpn = file_reader.find_icpn full_path
    icpn.should eql(nil)
  end
end # describe FileReader

