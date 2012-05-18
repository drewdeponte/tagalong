require 'rubygems'
require 'bundler/setup'

require File.expand_path('../../lib/tagalong', __FILE__)

require File.expand_path('spec/support/setup_database')

RSpec.configure do |c|
  c.before(:each) do
    clean_database!
  end
end
