require 'rubygems'
require 'bundler/setup'

require File.expand_path('../../lib/tagalong', __FILE__)

require File.expand_path('spec/support/setup_database')

require 'sunspot_solr'

RSpec.configure do |c|
  c.before(:each) do
    clean_database!
  end

  c.before(:all, :search => true) do
    Sunspot::Solr::Server.new.start
    sleep 7
  end

  c.before(:each, :search => true) do
    Sunspot.remove_all!
    Sunspot.commit
  end

  c.after(:all, :search => true) do
    Sunspot::Solr::Server.new.stop
  end
end
