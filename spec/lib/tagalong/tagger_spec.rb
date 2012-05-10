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
      it "returns list of tags the tagger has used"
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
    end
  end
end
