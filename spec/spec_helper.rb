ENV["RES_TOP"] ||= File.expand_path(File.dirname(__FILE__) + "/../../..")
ENV["RES_ENV"] ||= 'test'
require File.join(ENV["RES_TOP"],"glue/ruby/init.rb")
require 'rubygems'
require 'spec'

EMI_CONFIG[:couchdb][:server_url] = "http://localhost:5984"
EMI_CONFIG[:couchdb][:primary_db_name] = "shovel-db-spec"

# black magic
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "../../lib")