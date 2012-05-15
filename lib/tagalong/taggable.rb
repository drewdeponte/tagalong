module Tagalong
  module Taggable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def tagalong_taggable
        class_eval do
          has_many :tagalong_taggings, :class_name => 'Tagalong::TagalongTagging', :as => :taggable
          has_many :tagalong_tags, :class_name => 'Tagalong::TagalongTag', :through => :tagalong_taggings
          include Tagalong::Taggable::InstanceMethods
        end
      end
    end

    module InstanceMethods
      def tagged_with?(name)
        return self.tagalong_tags.map { |r| r.name }.include?(name)
      end

      def tags
        return self.tagalong_tags.order("name ASC").map { |r| r.name }
      end
    end
  end
end
