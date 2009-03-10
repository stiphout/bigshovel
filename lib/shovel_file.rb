require 'lazyboy'

class ShovelFileRecord < Records::Record
  define do
    string :original_file_name, :required
    string :original_full_path, :required
    string :original_path, :required
    string :icpn
    int :file_size
    string :md5_checksum
  end
end

class ShovelFile < Lazyboy::Model
  has_records :shovel_file
  has_index :on_record => :shovel_file, :index_on => :original_full_path
  has_index :on_record => :shovel_file, :index_on => :icpn
end