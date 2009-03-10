# ask resurrection to set up our load path and set up EMI_CONFIG
ENV["RES_TOP"] ||= File.expand_path(File.dirname(__FILE__) + '/../../../')
require File.join(ENV["RES_TOP"],"glue/ruby/init.rb")

require 'records'
require 'lazyboy'