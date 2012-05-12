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
