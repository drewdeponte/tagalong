begin
  require 'sunspot'
  require 'sunspot/rails'
rescue LoadError
  puts "sunspot would allow you to search tags faster, please 'gem install sunspot'"
end

module Tagalong
  def self.enable_sunspot
    Sunspot::Adapters::InstanceAdapter.register(Sunspot::Rails::Adapters::ActiveRecordInstanceAdapter, ActiveRecord::Base)
    Sunspot::Adapters::DataAccessor.register(Sunspot::Rails::Adapters::ActiveRecordDataAccessor, ActiveRecord::Base)
    ActiveRecord::Base.module_eval { include(Sunspot::Rails::Searchable) }
    Tagalong::TagalongTag.searchable do
      integer :tagger_id
      integer :number_of_references
      string :tagger_type
      text :name
    end
  end

  def self.sunspot_enabled?
    Tagalong::TagalongTag.searchable? ? true : false
  end

  def self.reindex_sunspot
    Tagalong::TagalongTag.reindex
  end
end
