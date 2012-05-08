module Tagalong
  class TagalongTagging < ::ActiveRecord::Base
    belongs_to :tagalong_tag, :class_name => 'Tagalong::TagalongTag'
    belongs_to :taggable, :polymorphic => true

    validates_presence_of :tagalong_tag_id
    validates_presence_of :tagalong_tag_id, :scope => [ :taggable_type, :taggable_id ]
  end
end
