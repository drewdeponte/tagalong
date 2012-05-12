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
      def has_tag?(name)
        return self.tagalong_tags(true).map { |r| r.name }.include?(name)
      end

      def tags
        return self.tagalong_tags(true).order("number_of_references DESC").map { |r| r.name }
      end
    end
  end
end
