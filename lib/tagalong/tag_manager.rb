module Tagalong
  class TagManager
    def initialize(taggable, tagger)
      @taggable = taggable
      @tagger = tagger
    end

    def add_tag(name)
      tagger_tag = tagger_used_tag?(name)
      if (tagger_tag != nil)
        if !taggable_has_tag?(name)
          associate_tag_with_taggable(tagger_tag, @taggable)
        end
      else
        tagger_tag = create_tag_for_tagger(name, @tagger)
        associate_tag_with_taggable(tagger_tag, @taggable)
      end
    end

    def remove_tag(name)
      tagger_tag = tagger_used_tag?(name)
      if tagger_tag && taggable_has_tag?(name)
        disassociate_tag_from_taggable(tagger_tag, @taggable)
      end
    end

    def tagger_used_tag?(name)
      @tagger.tagalong_tags.find_by_name(name)
    end

    def taggable_has_tag?(name)
      @taggable.tagalong_tags.find_by_name(name)
    end

    private

    def create_tag_for_tagger(name, tagger)
      return TagalongTag.create!(:tagger_id => tagger.id, :tagger_type => tagger.class.to_s, :name => name)
    end
    
    def associate_tag_with_taggable(tag, taggable)
      TagalongTagging.create!(:taggable_id => taggable.id, :taggable_type => taggable.class.to_s, :tagalong_tag_id => tag.id)
      increment_tag_number_of_references(tag)
    end

    def disassociate_tag_from_taggable(tag, taggable)
      taggable_tagging = TagalongTagging.find_by_tagalong_tag_id_and_taggable_id(tag.id, taggable.id)
      TagalongTagging.destroy(taggable_tagging.id)
      taggable.tagalong_tags(true)
      decrement_tag_number_of_references(tag)
    end

    def increment_tag_number_of_references(tag)
      tag.number_of_references = (tag.number_of_references || 0) + 1
      tag.save!
    end

    def decrement_tag_number_of_references(tag)
      tag.number_of_references = tag.number_of_references ? tag.number_of_references - 1 : 0
      tag.save!
    end
  end
end
