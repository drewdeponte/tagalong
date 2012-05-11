module Tagalong
  module Tagger
    def self.included(base)
      base.extend Tagalong::Tagger::ClassMethods
    end

    module ClassMethods
      def tagalong_tagger
        class_eval do
          has_many :tagalong_tags, :class_name => 'Tagalong::TagalongTag', :as => :tagger
          include Tagalong::Tagger::InstanceMethods
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
        tag_manager.remove_tag(tag_name)
      end

      def tags(taggable = nil)
        if taggable == nil
          return self.tagalong_tags.order("number_of_references DESC").map { |r| r.name }
        else
          return self.tagalong_tags.order("number_of_references DESC").map { |r| { :tag => r.name, :used => taggable.has_tag?(r.name), :number_of_references => r.number_of_references } }
        end
      end
    end
  end
end
