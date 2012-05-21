require 'rubygems'
require 'bundler/setup'

require File.expand_path('../../lib/tagalong', __FILE__)

require File.expand_path('spec/support/setup_database')

require 'sunspot_test/rspec'

SunspotTest.solr_startup_timeout = 60

RSpec.configure do |c|
  c.before(:each) do
    clean_database!
  end
end
