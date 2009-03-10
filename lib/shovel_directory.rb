require 'lazyboy'

class ShovelDirectoryRecord < Records::Record
  define do
    string :original_full_path, :required
    string :icpn
    int :file_count
  end
end

class ShovelDirectory < Lazyboy::Model
  has_records :shovel_directory
  has_index :on_record => :shovel_directory, :index_on => :original_full_path
  has_index :on_record => :shovel_directory, :index_on => :icpn
end