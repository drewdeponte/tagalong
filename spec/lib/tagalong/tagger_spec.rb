require 'spec_helper'

# The User class which is used in this spec as our tagger
# model, it is defined in the spec/models.rb file.

describe "Tagger" do
  before(:each) do
    @user = User.create!(:name => "My Owner")
    @contact = Contact.create!(:name => "My Taggable")
  end
  
  describe "Integration" do
    describe "#tag" do
      it "tags the given taggable object with the given tag name" do
        @user.tag(@contact, "foo")
        @contact.tagalong_tags.map { |r| r.name }.should include("foo")
      end
    end

    describe "#untag" do
      it "untags the tag from the given taggable object for the tagger" do
        @contact.tagalong_tags.create!(:name => "bar", :tagger_id => @user.id, :tagger_type => @user.class.to_s)
        @user.untag(@contact, "bar")
        @contact.tagalong_tags.map { |r| r.name }.should_not include("bar")
      end
    end

    describe "#tags" do
      context "without a taggable" do
        it "returns list of tags the tagger has used" do
          @user.tagalong_tags.create!(:name => "foo")
          @user.tagalong_tags.create!(:name => "bar")
          @user.tagalong_tags.create!(:name => "car")
          @user.tags.should == ["foo", "bar", "car"]
        end

        it "returns the list of tags in descending order of number of references" do
          @user.tagalong_tags.create!(:name => "foo", :number_of_references => 20)
          @user.tagalong_tags.create!(:name => "bar", :number_of_references => 100)
          @user.tagalong_tags.create!(:name => "car", :number_of_references => 8)
          @user.tags.should == ["bar", "foo", "car"]
        end
      end

      context "with a taggable" do
        it "returns a hash of the tags with usage information about the passed taggable" do
          tag = @user.tagalong_tags.create!(:name => "foo", :number_of_references => 1)
          @contact.tagalong_taggings.create!(:tagalong_tag_id => tag.id)
          @user.tagalong_tags.create!(:name => "bar", :number_of_references => 0)
          tag = @user.tagalong_tags.create!(:name => "car", :number_of_references => 1)
          @contact.tagalong_taggings.create!(:tagalong_tag_id => tag.id)
          @user.tags(@contact).should == [
            { :tag => "foo", :used => true, :number_of_references => 1  },
            { :tag => "car", :used => true, :number_of_references => 1 },
            { :tag => "bar", :used => false, :number_of_references => 0 }
          ]
        end

        it "returns a hash of tags with usage information about the passed taggable on secondary calls when the taggable changes" do
          tag = @user.tagalong_tags.create!(:name => "foo", :number_of_references => 1)
          @contact.tagalong_taggings.create!(:tagalong_tag_id => tag.id)
          @user.tagalong_tags.create!(:name => "bar", :number_of_references => 0)
          tag = @user.tagalong_tags.create!(:name => "car", :number_of_references => 1)
          @contact.tagalong_taggings.create!(:tagalong_tag_id => tag.id)
          @user.tags(@contact).should == [
            { :tag => "foo", :used => true, :number_of_references => 1  },
            { :tag => "car", :used => true, :number_of_references => 1 },
            { :tag => "bar", :used => false, :number_of_references => 0 }
          ]
          @other_contact = Contact.create!(:name => "My Other Taggable")
          tag = @user.tagalong_tags.create!(:name => "jones", :number_of_references => 1)
          @other_contact.tagalong_taggings.create!(:tagalong_tag_id => tag.id)
          tag = @user.tagalong_tags.create!(:name => "jimmy", :number_of_references => 2)
          @other_contact.tagalong_taggings.create!(:tagalong_tag_id => tag.id)
          @user.tags(@other_contact).should == [
            { :tag => "jimmy", :used => true, :number_of_references => 2  },
            { :tag => "foo", :used => false, :number_of_references => 1  },
            { :tag => "car", :used => false, :number_of_references => 1 },
            { :tag => "jones", :used => true, :number_of_references => 1 },
            { :tag => "bar", :used => false, :number_of_references => 0 }
          ]
        end
      end
    end

    describe "#taggables_with" do
      it "returns a collection of the taggables tagged with the given tag" do
        @user.tag(@contact, "jackson")
        @user.taggables_with("jackson").should == [@contact]
      end

      it "returns an empty array if it has no matching taggables" do
        @user.taggables_with("jackson_five").should == []
      end
    end
  end

  describe "Isolation" do
    describe "#tag" do
      it "creates an instance of the tag manager" do
        tag_manager = stub('tag_manager', :add_tag => nil)
        Tagalong::TagManager.should_receive(:new).with(@contact, @user).and_return(tag_manager)
        @user.tag(@contact, "foo")
      end

      it "tells the tag manager instance to tag the given taggable for tagger (self)" do
        tag_manager = mock('tag_manager')
        Tagalong::TagManager.stub(:new).with(@contact, @user).and_return(tag_manager)
        tag_manager.should_receive(:add_tag).with("foo")
        @user.tag(@contact, "foo")
      end

      it "raises taggable not persisted exception if attempting to tag a non-persisted taggable" do
        new_contact = Contact.new
        lambda { @user.tag(new_contact, "bar") }.should raise_error(Tagalong::TaggableNotPersisted)
      end
    end

    describe "#untag" do
      it "creates an instance of the tag manager" do
        tag_manager = stub('tag_manager', :remove_tag => nil)
        Tagalong::TagManager.should_receive(:new).with(@contact, @user).and_return(tag_manager)
        @user.untag(@contact, "bar")
      end

      it "tells the tag manager instance to untag the given taggable for tagger (self)" do
        tag_manager = mock('tag_manager')
        Tagalong::TagManager.stub(:new).with(@contact, @user).and_return(tag_manager)
        tag_manager.should_receive(:remove_tag).with("bar")
        @user.untag(@contact, "bar")
      end

      it "raises taggable not persisted exception if attempting to untag a non-persisted taggable" do
        new_contact = Contact.new
        lambda { @user.untag(new_contact, "bar") }.should raise_error(Tagalong::TaggableNotPersisted)
      end
    end
  end
end
