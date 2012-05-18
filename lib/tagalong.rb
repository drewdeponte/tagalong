require "active_record"

require "tagalong/version"
require "tagalong/exceptions"
require "tagalong/tagalong_tag"
require "tagalong/tagalong_tagging"
require "tagalong/tag_manager"
require "tagalong/taggable"
require "tagalong/tagger"

if defined?(ActiveRecord::Base)
  class ActiveRecord::Base
    include Tagalong::Taggable
    include Tagalong::Tagger
  end
end

module Tagalong
  def self.enable_sunspot
    Tagalong::TagalongTag.searchable do
      integer :tagger_id
      string :tagger_type
      text :name, :stored => true
    end
  end
end
