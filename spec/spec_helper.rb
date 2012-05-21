require 'rubygems'
require 'bundler/setup'

require File.expand_path('../../lib/tagalong', __FILE__)

require File.expand_path('spec/support/setup_database')

require 'sunspot_solr'

require 'net/http'

def solr_startup_timeout
  15
end

def solr_running?
  begin
    solr_ping_uri = URI.parse("#{Sunspot.session.config.solr.url}/ping")
    Net::HTTP.get(solr_ping_uri)
    true
  rescue
    false
  end
end

def wait_until_solr_starts
  (solr_startup_timeout * 10).times do
    break if solr_running?
    sleep(0.1)
  end
  raise TimeOutError, "Solr failed to start after #{solr_startup_timeout} seconds" unless solr_running?
end

RSpec.configure do |c|
  c.before(:each) do
    clean_database!
  end

  c.before(:all, :search => true) do
    Sunspot::Solr::Server.new.start
    wait_until_solr_starts
  end

  c.before(:each, :search => true) do
    Sunspot.remove_all!
    Sunspot.commit
  end

  c.after(:all, :search => true) do
    Sunspot::Solr::Server.new.stop
  end
end
