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
        raise Tagalong::TaggableNotPersisted, "Taggable must be persisted to tag it." if !taggable_obj.persisted?
        tag_manager = Tagalong::TagManager.new(taggable_obj, self)
        tag_manager.add_tag(tag_name)
      end

      def untag(taggable_obj, tag_name)
        raise Tagalong::TaggableNotPersisted, "Taggable must be persisted to untag it." if !taggable_obj.persisted?
        tag_manager = Tagalong::TagManager.new(taggable_obj, self)
        tag_manager.remove_tag(tag_name)
      end

      def tags(taggable = nil)
        if taggable == nil
          return self.tagalong_tags.order("number_of_references DESC").map { |r| r.name }
        else
          return self.tagalong_tags.
                  joins("LEFT OUTER JOIN tagalong_taggings ON tagalong_taggings.tagalong_tag_id = tagalong_tags.id AND tagalong_taggings.taggable_id = '#{taggable.id.to_s}'").
                  select("tagalong_tags.id, tagalong_tags.name, tagalong_tags.number_of_references, tagalong_taggings.id as used").
                  order("number_of_references DESC").map { |r| { :tag => r.name, :used => !r.used.nil?, :number_of_references => r.number_of_references } }
        end
      end

      def taggables_with(name)
        self.tagalong_tags.where(:name => name).each do |t|
          return t.taggables
        end
      end
    end
  end
end
