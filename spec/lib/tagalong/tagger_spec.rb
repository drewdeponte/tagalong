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

    describe "#create_tag" do
      it "creates a new unassigned tag on the tagger" do
        @user.create_tag('tag4')
        @user.tags.should include('tag4')
      end
    end

    describe "#untag" do
      it "untags the tag from the given taggable object for the tagger" do
        @contact.tagalong_tags.create!(:name => "bar", :tagger_id => @user.id, :tagger_type => @user.class.to_s)
        @user.untag(@contact, "bar")
        @contact.tagalong_tags.map { |r| r.name }.should_not include("bar")
      end
    end

    describe "#delete_tag" do
      before(:each) do
        @user.tag(@contact, "tag1")
      end

      it "should disassociate the tag that belongs to it" do
        @user.delete_tag('tag1')
        @user.tags.should_not include("tag1")
      end

      it "should destroy the tag record from the db" do
        @user.delete_tag('tag1')
        Tagalong::TagalongTag.find_by_name('tag1').should_not be_present
      end

      it "should not destroy tags it does not have" do
        Tagalong::TagalongTag.create(:tagger_type => 'FakeTagger', :tagger_id => 1, :name => 'badTag')
        @user.delete_tag('badTag')
        Tagalong::TagalongTag.find_by_name('badTag').should be_present
      end
    end

    describe "#has_tag?" do
      context "the tagger has the tag" do
        before(:each) do
          @user.create_tag('tag5')
        end

        it {@user.has_tag?('tag5').should be_true}
      end

      context "the tagger does not have the tag" do
        it {@user.has_tag?('tag99').should be_false}
      end
    end

    describe "#tags" do
      context "without a taggable" do
        it "returns list of tags the tagger has used" do
          @user.tagalong_tags.create!(:name => "foo")
          @user.tagalong_tags.create!(:name => "bar")
          @user.tagalong_tags.create!(:name => "car")
          @user.tags.should == ["bar", "car", "foo"]
        end

        it "returns the list of tags in ascending alphabetical order" do
          @user.tagalong_tags.create!(:name => "foo", :number_of_references => 20)
          @user.tagalong_tags.create!(:name => "bar", :number_of_references => 100)
          @user.tagalong_tags.create!(:name => "car", :number_of_references => 8)
          @user.tags.should == ["bar", "car", "foo"]
        end
      end
    end

    describe "#tags_including" do
      before(:each) do
        @user.tag(@contact, "tag1")
        @user.tag(@contact, "tag2")
      end

      context "without options passed" do
        it "should return an array of hashes with name" do
          @user.tags_including.should == [
            {:name => 'tag1'},
            {:name => 'tag2'}
          ]
        end
      end
      
      context "with number_of_references passed" do
        it "should return an array of hashes with name and number_of_references" do
          @user.tags_including(:number_of_references => true).should == [
            {:name => 'tag1', :number_of_references => 1},
            {:name => 'tag2', :number_of_references => 1}
          ]
        end
      end

      context "with a valid taggable passed as has_been_tagged" do
        it "should return an array of hashes with name and has_been_tagged" do
          @contact2 = Contact.create!(:name => "My Taggable 2")
          @user.tag(@contact2, 'tag3')
          @user.tags_including(:has_been_tagged => @contact).should == [
            {:name => 'tag1', :has_been_tagged => true},
            {:name => 'tag2', :has_been_tagged => true},
            {:name => 'tag3', :has_been_tagged => false}
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

    describe "#create_tag" do
      it "creates a new tagalong tag for the tagger" do
        Tagalong::TagalongTag.should_receive(:create!).with(hash_including({:tagger_id => @user.id, :tagger_type => @user.class.to_s, :name => 'tag4'}))
        @user.create_tag('tag4')
      end
    end

    describe "#has_tag?" do
      it "should try the list of tags for the tagger" do
        tags = mock('tags')
        @user.stub(:tags).and_return(tags)
        tags.should_receive(:include?).with('tag5')
        @user.has_tag?('tag5')
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
