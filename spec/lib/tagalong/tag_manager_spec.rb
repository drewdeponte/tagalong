require_relative "../../../lib/tagalong/tag_manager"

class TagalongTag; end
class TagalongTagging; end

describe Tagalong::TagManager do
  before(:each) do
    @taggable = stub('managed_contact', :id => 58, :class => "Contact")
    @owner = stub('tag_owner', :id => 23, :class => "User")
    @tag_manager = Tagalong::TagManager.new(@taggable, @owner)
  end

  describe "#add_tag" do
    context "owner does NOT already have the tag" do
      before(:each) do
        @tag_manager.stub(:owner_has_tag?).and_return(nil)
      end

      it "creates a tag for the owner" do
        @tag_manager.should_receive(:create_tag_for_owner).with("foo_tag", @owner)
        @tag_manager.stub(:associate_tag_with_contact)
        @tag_manager.add_tag("foo_tag")
      end

      it "associates the created owner tag with the managed contact" do
        cm_contact_tag = stub('cm_contact_tag', :id => 98)
        @tag_manager.stub(:create_tag_for_owner).and_return(cm_contact_tag)
        @tag_manager.should_receive(:associate_tag_with_contact).with(cm_contact_tag, @taggable)
        @tag_manager.add_tag("foo_tag")
      end
    end

    context "owner already has the tag" do
      before(:each) do
        @cm_contact_tag = stub('cm_contact_tag', :id => 108)
        @tag_manager.stub(:owner_has_tag?).and_return(@cm_contact_tag)
      end

      it "does NOT create a new tag for the owner" do
        @tag_manager.stub(:contact_has_tag?).and_return(stub('cm_contact_tag'))
        @tag_manager.should_not_receive(:create_tog_for_owner)
        @tag_manager.add_tag("foo_tag")
      end

      context "tag is already associated to the contact" do
        before(:each) do
          cm_contact_tag = stub('cm_contact_tag')
          @tag_manager.stub(:contact_has_tag?).and_return(cm_contact_tag)
        end

        it "does NOT associated the matching TagalongTag record with a CmContact via a TagalongTagging" do
          @tag_manager.should_not_receive(:associate_tag_with_contact)
          @tag_manager.add_tag("foo_tag")
        end
      end

      context "tag is NOT associated to the contact" do
        before(:each) do
          @tag_manager.stub(:contact_has_tag?).and_return(nil)
        end

        it "associates the owner matching TagalongTag record with a CmContact via a TagalongTagging" do
          @tag_manager.should_receive(:associate_tag_with_contact).with(@cm_contact_tag, @taggable)
          @tag_manager.add_tag("foo_tag")
        end
      end
    end
  end

  describe "#remove_tag" do
    it "disassociates the tag from the managed contact if currently associated" do
      cm_contact_tag = stub('cm_contact_tag')
      @tag_manager.stub(:contact_has_tag?).and_return(cm_contact_tag)
      @tag_manager.should_receive(:disassociate_tag_from_contact).with(cm_contact_tag, @taggable)
      @tag_manager.remove_tag("foo_tag")
    end

    it "should NOT dissassociate the tag from the managed contact if it is NOT associated" do
      @tag_manager.stub(:contact_has_tag?).and_return(nil)
      @tag_manager.should_not_receive(:disassociate_tag_from_contact)
      @tag_manager.remove_tag("foo_tag")
    end
  end

  describe "#owner_has_tag?" do
    it "returns the matching TagalongTag if the owner already has the tag" do
      cm_contact_tag = stub('cm_contact_tag')
      @owner.stub_chain(:cm_contact_tags, :find_by_name).and_return(cm_contact_tag)
      @tag_manager.owner_has_tag?("foo_tag").should == cm_contact_tag
    end

    it "returns nil if the owner does NOT already have the tag" do
      @owner.stub_chain(:cm_contact_tags, :find_by_name).and_return(nil)
      @tag_manager.owner_has_tag?("foo_tag").should be_nil
    end
  end

  describe "#contact_has_tag?" do
    it "returns matching TagalongTag if the contact is already associated to the tag" do
      cm_contact_tag = stub('cm_contact_tag')
      @taggable.stub_chain(:cm_contact_tags, :find_by_name).and_return(cm_contact_tag)
      @tag_manager.contact_has_tag?("foo_tag").should == cm_contact_tag
    end

    it "returns nil, if the tag is NOT already associated with the contact" do
      @taggable.stub_chain(:cm_contact_tags, :find_by_name).and_return(nil)
      @tag_manager.contact_has_tag?("foo_tag").should be_nil
    end
  end

  describe "#create_tag_for_owner" do
    it "creates a TagalongTag record associated with the owner with the given name" do
      TagalongTag.should_receive(:create!).with({ :owner_id => @owner.id, :owner_type => "User", :name => "hoopty" })
      @tag_manager.send(:create_tag_for_owner, "hoopty", @owner)
    end
  end

  describe "#associate_tag_with_contact" do
    it "creates a TagalongTagging record associated with the given contact and tag" do
      cm_contact_tag = stub('cm_contact_tag', :id => 214)
      @tag_manager.stub(:increment_tag_number_of_references)
      TagalongTagging.should_receive(:create!).with({ :taggable_id => @taggable.id, :taggable_type => "Contact", :tagalong_tag_id => 214 })
      @tag_manager.send(:associate_tag_with_contact, cm_contact_tag, @taggable)
    end

    it "increments the reference count for the tag" do
      cm_contact_tag = stub('cm_contact_tag', :id => stub)
      TagalongTagging.stub(:create!)
      @tag_manager.should_receive(:increment_tag_number_of_references).with(cm_contact_tag)
      @tag_manager.send(:associate_tag_with_contact, cm_contact_tag, @taggable)
    end
  end

  describe "#disassociate_tag_from_contact" do
    it "deletes the TagalongTagging record that associates the given tag with the given contact" do
      cm_contact_tag = stub('cm_contact_tag', :id => 111)
      cm_contact_tagging = mock('cm_contact_tagging')
      TagalongTagging.stub(:find_by_cm_contact_tag_id_and_cm_contact_id).with(111, @taggable.id).and_return(cm_contact_tagging)
      @tag_manager.stub(:decrement_tag_number_of_references)
      cm_contact_tagging.should_receive(:delete)
      @tag_manager.send(:disassociate_tag_from_contact, cm_contact_tag, @taggable)
    end

    it "decrements the reference count of the tag" do
      cm_contact_tag = stub('cm_contact_tag', :id => 111)
      cm_contact_tagging = stub('cm_contact_tagging', :delete => nil)
      TagalongTagging.stub(:find_by_cm_contact_tag_id_and_cm_contact_id).and_return(cm_contact_tagging)
      @tag_manager.should_receive(:decrement_tag_number_of_references).with(cm_contact_tag)
      @tag_manager.send(:disassociate_tag_from_contact, cm_contact_tag, @taggable)
    end
  end

  describe "#increment_tag_number_of_references" do
    it "increments the number_of_references attribute for the tag object" do
      cm_contact_tag = mock('cm_contact_tag', :number_of_references => 13, :save! => nil)
      cm_contact_tag.should_receive(:number_of_references=).with(14)
      @tag_manager.send(:increment_tag_number_of_references, cm_contact_tag)
    end

    it "initializes number_of_referencs to 1 if number_of_references is nil" do
      cm_contact_tag = mock('cm_contact_tag', :number_of_references => nil, :save! => nil)
      cm_contact_tag.should_receive(:number_of_references=).with(1)
      @tag_manager.send(:increment_tag_number_of_references, cm_contact_tag)
    end

    it "saves the changes to the database" do
      cm_contact_tag = mock('cm_contact_tag', :number_of_references => 13, :number_of_references= => nil)
      cm_contact_tag.should_receive(:save!)
      @tag_manager.send(:increment_tag_number_of_references, cm_contact_tag)
    end
  end

  describe "#decrement_tag_number_of_references" do
    it "decrements the number_of_references attribute for the tag object" do
      cm_contact_tag = mock('cm_contact_tag', :number_of_references => 13, :save! => nil)
      cm_contact_tag.should_receive(:number_of_references=).with(12)
      @tag_manager.send(:decrement_tag_number_of_references, cm_contact_tag)
    end

    it "initializes number_of_references to zero if number_of_references is nil" do
      cm_contact_tag = mock('cm_contact_tag', :number_of_references => nil, :save! => nil)
      cm_contact_tag.should_receive(:number_of_references=).with(0)
      @tag_manager.send(:decrement_tag_number_of_references, cm_contact_tag)
    end

    it "saves the changes to the database" do
      cm_contact_tag = mock('cm_contact_tag', :number_of_references => 13, :number_of_references= => nil)
      cm_contact_tag.should_receive(:save!)
      @tag_manager.send(:decrement_tag_number_of_references, cm_contact_tag)
    end
  end
end
