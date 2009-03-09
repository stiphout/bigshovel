require 'lazyboy'

class ManifestItemRecord < Records::Record
  define do
    string :type, :required
    string :name, :required
    string :serial_number
    string :path
    string :size
    string :items
    string :date
    string :time
  end
end

class ManifestItem < Lazyboy::Model
  has_records :manifest_item
  has_index :on_record => :manifest_item, :index_on => :name
end
