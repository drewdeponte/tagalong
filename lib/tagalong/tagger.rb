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

      def create_tag(tag_name)
        raise Tagalong::TagAlreadyInUse, "A tag already exists with the name '#{tag_name}'" if tagalong_tags.find_by_name(tag_name).present?
        raise Tagalong::TagCannotBeBlank, "A tag cannot have a blank name" if tag_name.blank?
        TagalongTag.create!(:tagger_id => self.id, :tagger_type => self.class.to_s, :name => tag_name)
      end

      def rename_tag(existing_tag, rename_to)
        if tag = tagalong_tags.find_by_name(existing_tag)
          raise Tagalong::TagAlreadyInUse, "A tag already exists with the name '#{rename_to}'" if tagalong_tags.find_by_name(rename_to).present?
          raise Tagalong::TagCannotBeBlank, "A tag cannot have a blank name" if rename_to.blank?
          tag.update_attribute(:name, rename_to)
        else
          raise Tagalong::TagNotFound, "Tried to rename a tag that does not exist."
        end
      end

      def untag(taggable_obj, tag_name)
        raise Tagalong::TaggableNotPersisted, "Taggable must be persisted to untag it." if !taggable_obj.persisted?
        tag_manager = Tagalong::TagManager.new(taggable_obj, self)
        tag_manager.remove_tag(tag_name)
      end

      def delete_tag(tag_name)
        tag = tagalong_tags.find_by_name(tag_name)
        if tag.present?
          tag.destroy
        end
      end

      def has_tag?(tag_name)
        tags.include?(tag_name)
      end

      def tags
        self.tagalong_tags.order("name ASC").map { |r| r.name }
      end

      def tags_including(options={})
        out = []
        query = self.tagalong_tags.order("name ASC")

        if options[:has_been_tagged]
          query = query.
                    select("tagalong_tags.id, tagalong_tags.name, tagalong_tags.number_of_references, tagalong_taggings.id as used").
                    joins("LEFT OUTER JOIN tagalong_taggings ON tagalong_taggings.tagalong_tag_id = tagalong_tags.id AND tagalong_taggings.taggable_id = '#{options[:has_been_tagged].id.to_s}'")
        end
        
        query.each do |tag|
          hash = {:name => tag.name}
          if options[:number_of_references]
            hash[:number_of_references] = tag.number_of_references
          end
          if options[:has_been_tagged]
            hash[:has_been_tagged] = !tag.used.nil?
          end
          out << hash
        end
        
        return out
      end

      def tags_matching(search_phrase)
        if Tagalong.sunspot_enabled?
          tmp_tagger_type = self.class.to_s # this is needed because self.class apparently changes inside the Sunspot.search scope.
          tag_search = Sunspot.search(Tagalong::TagalongTag) do
            fulltext "\"#{search_phrase}\""
            with :tagger_id, self.id
            with :tagger_type, tmp_tagger_type
            order_by(:number_of_references, :desc)
          end
          tag_search.results.map { |r| { :name => r.name, :number_of_references => r.number_of_references } }
        else
          self.tagalong_tags.order("number_of_references DESC").where("name like ?", ["%#{search_phrase}%"]).map { |r| { :name => r.name } }
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
