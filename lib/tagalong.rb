require "active_record"

require "tagalong/version"

require "tagalong/tagalong_tag"
require "tagalong/tagalong_tagging"

require "tagalong/taggable"
require "tagalong/owner"

require "tagalong/tag_manager"

if defined?(ActiveRecord::Base)
  class ActiveRecord::Base
    include Tagalong::Taggable
    include Tagalong::Owner
  end
end
