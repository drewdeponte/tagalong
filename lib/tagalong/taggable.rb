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
      def tags
      end
    end
  end
end
