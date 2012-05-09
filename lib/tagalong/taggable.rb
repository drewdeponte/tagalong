module Tagalong
  module Taggable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def tagalong_taggable
        class_eval do
          has_many :tagalong_taggings, :class_name => 'Tagalong::TagalongTagging', :foreign_key => 'taggable_id'
          has_many :tagalong_tags, :class_name => 'Tagalong::TagalongTag', :through => :tagalong_taggings
          include Tagalong::Taggable::InstanceMethods
        end
      end
    end

    module InstanceMethods
      def add_tag(tag_name)
        puts "woot tag #{tag_name} would be added"
      end

      def remove_tag(tag_name)
        puts "woot tag #{tag_name} would be removed"
      end
    end
  end
end
