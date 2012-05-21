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
    ::Sunspot.setup(Tagalong::TagalongTag) do
      integer :tagger_id
      integer :number_of_references
      string :tagger_type
      text :name
    end
  end

  def self.sunspot_enabled?
    Sunspot.searchable.include?(Tagalong::TagalongTag)
  end

  def self.reindex_sunspot
    Sunspot.remove_all(Tagalong::TagalongTag)
    Sunspot.index!(Tagalong::TagalongTag.all)
    Sunspot.commit
  end
end
