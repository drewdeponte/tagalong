module Tagalong
  module Owner
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def tagalong_owner
        class_eval do
          has_many :tagalong_tags, :class_name => 'Tagalong::TagalongTag', :foreign_key => 'owner_id'
          include Tagalong::Owner::InstanceMethods
        end
      end
    end

    module InstanceMethods
      def tag(taggable_obj, tag_name)
        tag_manager = Tagalong::TagManager.new(taggable_obj, self)
        tag_manager.add_tag(tag_name)
      end

      def untag(taggable_obj, tag_name)
        tag_manager = Tagalong::TagManager.new(taggable_obj, self)
        # this needs to remove the tag associates from the taggable object where the owner matches self
        tag_manager.remove_tag(tag_name) # FIX: This function currently doesn't take into consideration the owner and it needs to
      end

      def tags
      end
    end
  end
end
