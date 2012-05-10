require_relative "../../../lib/tagalong/tag_manager"

class TagalongTag; end
class TagalongTagging; end

describe Tagalong::TagManager do
  before(:each) do
    @taggable = stub('taggable', :id => 58, :class => "Contact", :reload => nil)
    @tagger = stub('tagger', :id => 23, :class => "User")
    @tag_manager = Tagalong::TagManager.new(@taggable, @tagger)
  end

  describe "#add_tag" do
    context "tagger does NOT already have the tag" do
      before(:each) do
        @tag_manager.stub(:tagger_used_tag?).and_return(nil)
      end

      it "creates a tag for the tagger" do
        @tag_manager.should_receive(:create_tag_for_tagger).with("foo_tag", @tagger)
        @tag_manager.stub(:associate_tag_with_taggable)
        @tag_manager.add_tag("foo_tag")
      end

      it "associates the created tagger tag with the taggable" do
        tag = stub('tag', :id => 98)
        @tag_manager.stub(:create_tag_for_tagger).and_return(tag)
        @tag_manager.should_receive(:associate_tag_with_taggable).with(tag, @taggable)
        @tag_manager.add_tag("foo_tag")
      end
    end

    context "tagger already has the tag" do
      before(:each) do
        @tag = stub('tag', :id => 108)
        @tag_manager.stub(:tagger_used_tag?).and_return(@tag)
      end

      it "does NOT create a new tag for the tagger" do
        @tag_manager.stub(:taggable_has_tag?).and_return(@tag)
        @tag_manager.should_not_receive(:create_tag_for_tagger)
        @tag_manager.add_tag("foo_tag")
      end

      context "tag is already associated to the taggable" do
        before(:each) do
          @tag_manager.stub(:taggable_has_tag?).and_return(@tag)
        end

        it "does NOT associated the matching tag record with taggable" do
          @tag_manager.should_not_receive(:associate_tag_with_taggable)
          @tag_manager.add_tag("foo_tag")
        end
      end

      context "tag is NOT associated to the taggable" do
        before(:each) do
          @tag_manager.stub(:taggable_has_tag?).and_return(nil)
        end

        it "associates the tagger matched tag record with the taggable" do
          @tag_manager.should_receive(:associate_tag_with_taggable).with(@tag, @taggable)
          @tag_manager.add_tag("foo_tag")
        end
      end
    end
  end

  describe "#remove_tag" do
    it "disassociates the tag from the taggable if the tag belongs to tagger" do
      tag = stub('tag')
      @tag_manager.stub(:tagger_used_tag?).and_return(tag)
      @tag_manager.stub(:taggable_has_tag?).and_return(tag)
      @tag_manager.should_receive(:disassociate_tag_from_taggable).with(tag, @taggable)
      @tag_manager.remove_tag("foo_tag")
    end

    it "should NOT dissassociate the tag from the taggable if it does NOT belong to the tagger" do
      @tag_manager.stub(:tagger_used_tag?).and_return(stub('tag'))
      @tag_manager.stub(:taggable_has_tag?).and_return(nil)
      @tag_manager.should_not_receive(:disassociate_tag_from_taggable)
      @tag_manager.remove_tag("foo_tag")
    end
  end

  describe "#tagger_used_tag?" do
    it "returns the matching TagalongTag if the tagger has the tag" do
      tag = stub('tag')
      @tagger.stub_chain(:tagalong_tags, :find_by_name).and_return(tag)
      @tag_manager.tagger_used_tag?("foo_tag").should == tag
    end

    it "returns nil if the tagger does NOT have the tag" do
      @tagger.stub_chain(:tagalong_tags, :find_by_name).and_return(nil)
      @tag_manager.tagger_used_tag?("foo_tag").should be_nil
    end
  end

  describe "#taggable_has_tag?" do
    it "returns matching TagalongTag if the taggable is already associated with the tag" do
      tag = stub('tag')
      @taggable.stub_chain(:tagalong_tags, :find_by_name).and_return(tag)
      @tag_manager.taggable_has_tag?("foo_tag").should == tag
    end

    it "returns nil, if the tag is NOT already associated with the taggable" do
      @taggable.stub_chain(:tagalong_tags, :find_by_name).and_return(nil)
      @tag_manager.taggable_has_tag?("foo_tag").should be_nil
    end
  end

  describe "#create_tag_for_tagger" do
    it "creates a TagalongTag record with the given name, associated with the tagger object" do
      TagalongTag.should_receive(:create!).with({ :tagger_id => @tagger.id, :tagger_type => "User", :name => "hoopty" })
      @tag_manager.send(:create_tag_for_tagger, "hoopty", @tagger)
    end
  end

  describe "#associate_tag_with_taggable" do
    it "creates a TagalongTagging record associated with the given taggable and tag" do
      tag = stub('tag', :id => 214)
      @tag_manager.stub(:increment_tag_number_of_references)
      TagalongTagging.should_receive(:create!).with({ :taggable_id => @taggable.id, :taggable_type => "Contact", :tagalong_tag_id => 214 })
      @tag_manager.send(:associate_tag_with_taggable, tag, @taggable)
    end

    it "increments the reference count for the tag" do
      tag = stub('tag', :id => stub)
      TagalongTagging.stub(:create!)
      @tag_manager.should_receive(:increment_tag_number_of_references).with(tag)
      @tag_manager.send(:associate_tag_with_taggable, tag, @taggable)
    end
  end

  describe "#disassociate_tag_from_taggable" do
    it "destroys the TagalongTagging record that associates the given tag with the given taggable" do
      tag = stub('tag', :id => 111)
      tagging = mock('tagging', :id => 283)
      TagalongTagging.stub(:find_by_tagalong_tag_id_and_taggable_id).with(111, @taggable.id).and_return(tagging)
      @tag_manager.stub(:decrement_tag_number_of_references)
      TagalongTagging.should_receive(:destroy).with(283)
      @tag_manager.send(:disassociate_tag_from_taggable, tag, @taggable)
    end

    it "decrements the reference count of the tag" do
      tag = stub('tag', :id => 111)
      tagging = stub('tagging', :id => 283)
      TagalongTagging.stub(:find_by_tagalong_tag_id_and_taggable_id).and_return(tagging)
      TagalongTagging.stub(:destroy)
      @tag_manager.should_receive(:decrement_tag_number_of_references).with(tag)
      @tag_manager.send(:disassociate_tag_from_taggable, tag, @taggable)
    end
  end

  describe "#increment_tag_number_of_references" do
    it "increments the number of references for the tag" do
      tag = mock('tag', :number_of_references => 13, :save! => nil)
      tag.should_receive(:number_of_references=).with(14)
      @tag_manager.send(:increment_tag_number_of_references, tag)
    end

    it "initializes number of referencs to 1 if number of references is nil" do
      tag = mock('tag', :number_of_references => nil, :save! => nil)
      tag.should_receive(:number_of_references=).with(1)
      @tag_manager.send(:increment_tag_number_of_references, tag)
    end

    it "saves the changes to the database" do
      tag = mock('tag', :number_of_references => 13, :number_of_references= => nil)
      tag.should_receive(:save!)
      @tag_manager.send(:increment_tag_number_of_references, tag)
    end
  end

  describe "#decrement_tag_number_of_references" do
    it "decrements the number of references for the tag" do
      tag = mock('tag', :number_of_references => 13, :save! => nil)
      tag.should_receive(:number_of_references=).with(12)
      @tag_manager.send(:decrement_tag_number_of_references, tag)
    end

    it "initializes number of references to zero if number of references is nil" do
      tag = mock('tag', :number_of_references => nil, :save! => nil)
      tag.should_receive(:number_of_references=).with(0)
      @tag_manager.send(:decrement_tag_number_of_references, tag)
    end

    it "saves the changes to the database" do
      tag = mock('tag', :number_of_references => 13, :number_of_references= => nil)
      tag.should_receive(:save!)
      @tag_manager.send(:decrement_tag_number_of_references, tag)
    end
  end
end
