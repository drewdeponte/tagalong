module Tagalong
  class TagManager
    def initialize(contact, owner)
      @managed_contact = contact
      @managed_owner = owner
    end

    def add_tag(name)
      owner_matched_tag = owner_has_tag?(name)
      if owner_matched_tag
        contact_matched_tag = contact_has_tag?(name)
        if !contact_matched_tag
          associate_tag_with_contact(owner_matched_tag, @managed_contact)
        end
      else
        cm_contact_tag = create_tag_for_owner(name, @managed_owner)
        associate_tag_with_contact(cm_contact_tag, @managed_contact)
      end
    end

    def remove_tag(name)
      contact_matched_tag = contact_has_tag?(name)
      if contact_matched_tag
        disassociate_tag_from_contact(contact_matched_tag, @managed_contact)
      end
    end

    def owners_tags
      @managed_owner.cm_contact_tags.order('cm_contact_tags.number_of_references DESC').map { |r| r.name }
    end

    def owner_has_tag?(name)
      @managed_owner.cm_contact_tags.find_by_name(name)
    end

    def contact_has_tag?(name)
      @managed_contact.cm_contact_tags.find_by_name(name)
    end

    private

    def create_tag_for_owner(name, owner)
      return TagalongTag.create!(:owner_id => owner.id, :owner_type => owner.class, :name => name)
    end
    
    def associate_tag_with_contact(cm_contact_tag, contact)
      TagalongTagging.create!(:taggable_id => contact.id, :taggable_type => contact.class, :tagalong_tag_id => cm_contact_tag.id)
      increment_tag_number_of_references(cm_contact_tag)
    end

    def disassociate_tag_from_contact(cm_contact_tag, contact)
      contact_tagging = TagalongTagging.find_by_cm_contact_tag_id_and_cm_contact_id(cm_contact_tag.id, contact.id)
      contact_tagging.delete
      decrement_tag_number_of_references(cm_contact_tag)
    end

    def increment_tag_number_of_references(cm_contact_tag)
      cm_contact_tag.number_of_references = (cm_contact_tag.number_of_references || 0) + 1
      cm_contact_tag.save!
    end

    def decrement_tag_number_of_references(cm_contact_tag)
      cm_contact_tag.number_of_references = cm_contact_tag.number_of_references ? cm_contact_tag.number_of_references - 1 : 0
      cm_contact_tag.save!
    end
  end
end
