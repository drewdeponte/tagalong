require 'spec_helper'

# The User class which is used in this spec as our tagger
# model, it is defined in the spec/models.rb file.

describe "Tagger" do
  before(:each) do
    @user = User.create!(:name => "Tagger")
    @contact = Contact.create!(:name => "Taggable")
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
        @user.tagalong_tags.map { |t| t.name }.should include('tag4')
      end

      it "should not create the tag if the name is already in use" do
        @user.create_tag('tag4')
        lambda { @user.create_tag('tag4') }.should raise_error(Tagalong::TagAlreadyInUse)
      end

      it "should raise a cannot be blank error if the name is blank" do
        lambda { @user.create_tag('') }.should raise_error(Tagalong::TagCannotBeBlank)
      end
    end

    describe "#rename_tag" do
      context "when the tagger owns the tag being renamed" do
        before(:each) do
          @user.tagalong_tags.create!(:name => 'tag5')
        end

        it "changes the name of a tag" do
          @user.rename_tag('tag5', 'renamedTag5')
          @user.tagalong_tags.map { |t| t.name }.should == ['renamedTag5']
        end

        it "should not change the name of the tag if the name is already in use" do
          @user.tagalong_tags.create!(:name => 'renamedTag5')
          lambda { @user.rename_tag('tag5', 'renamedTag5') }.should raise_error(Tagalong::TagAlreadyInUse)
        end

        it "should return true if rename was successfull" do
          @user.rename_tag('tag5', 'renamedTag5').should be_true
        end

        it "should raise a cannot be blank error if the name is blank" do
          lambda { @user.rename_tag('tag5', '') }.should raise_error(Tagalong::TagCannotBeBlank)
        end
      end

      context "when the tagger does not own the tag being renamed" do
        it "should raise a tag not found error" do
          lambda { @user.rename_tag('tagDoesntExist', 'renamedTag6') }.should raise_error(Tagalong::TagNotFound)
        end

        it "should not let you update another taggers tag" do
          @user2 = User.create!(:name => "Tagger 2")
          @contact2 = Contact.create!(:name => "Taggable 2")
          @contact2.tagalong_tags.create!(:name => "tag20", :tagger => @user2)
          lambda { @user.rename_tag('tag20', 'renamedTag20') }.should raise_error(Tagalong::TagNotFound)
        end
      end

      it "should return raise an exception if the tag doesnt exist" do
        lambda { @user.rename_tag('tagThatDoesntExist', 'something') }.should raise_error(Tagalong::TagNotFound)
      end
    end

    describe "#untag" do
      it "untags the tag from the given taggable object for the tagger" do
        @contact.tagalong_tags.create!(:name => "bar", :tagger => @user)
        @user.untag(@contact, "bar")
        @contact.tagalong_tags.map { |r| r.name }.should_not include("bar")
      end
    end

    describe "#delete_tag" do
      before(:each) do
        @contact.tagalong_tags.create!(:name => "tag1", :tagger => @user)
      end

      it "should disassociate the tag that belongs to it" do
        @user.delete_tag('tag1')
        @user.tagalong_tags.should_not include("tag1")
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
          @user.tagalong_tags.create!(:name => 'tag5')
        end

        it { @user.has_tag?('tag5').should be_true }
      end

      context "the tagger does not have the tag" do
        it { @user.has_tag?('tag99').should be_false }
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
        @contact.tagalong_tags.create!(:name => "tag1", :number_of_references => 1, :tagger => @user)
        @contact.tagalong_tags.create!(:name => "tag2", :number_of_references => 1, :tagger => @user)
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
          @contact2.tagalong_tags.create!(:name => "tag3", :tagger => @user)
          @user.tags_including(:has_been_tagged => @contact).should == [
            {:name => 'tag1', :has_been_tagged => true},
            {:name => 'tag2', :has_been_tagged => true},
            {:name => 'tag3', :has_been_tagged => false}
          ]
        end
      end
    end

    describe "#tags_matching" do
      context "have not enabled sunspot" do
        before(:each) do
          Tagalong.stub(:sunspot_enabled?).and_return(false)
        end

        it "returns an array of hashes representing tags that match the given search phrase ordered by number of references descending" do
          @user.tagalong_tags.create!(:name => "foo bar kitty", :number_of_references => 1)
          @user.tagalong_tags.create!(:name => "bar foo house", :number_of_references => 3)
          @user.tagalong_tags.create!(:name => "hello foo bar town", :number_of_references => 2)
          @user.tags_matching("foo bar").should == [
            { :name => 'hello foo bar town' },
            { :name => 'foo bar kitty' }
          ]
        end
      end

      context "have enabled sunspot", :search => true do
        before(:each) do
          Tagalong.enable_sunspot
          Tagalong.stub(:sunspot_enabled?).and_return(true)
        end

        it "returns an array of hashes representing tags that match the given search phrase ordered by number of references descending" do
          @user.tagalong_tags.create!(:name => "foo bar kitty", :number_of_references => 1)
          @user.tagalong_tags.create!(:name => "bar foo house", :number_of_references => 3)
          @user.tagalong_tags.create!(:name => "hello foo bar town", :number_of_references => 2)

          # Sunspot.remove_all(Tagalong::TagalongTag)
          # Sunspot.index!(Tagalong::TagalongTag.all)
          # Sunspot.commit
          Tagalong::TagalongTag.reindex

          @user.tags_matching("foo bar").should == [
            { :name => 'hello foo bar town', :number_of_references => 2 },
            { :name => 'foo bar kitty', :number_of_references => 1 }
          ]
        end
      end
    end

    describe "#taggables_with" do
      it "returns a collection of the taggables tagged with the given tag" do
        @contact.tagalong_tags.create!(:name => "jackson", :tagger => @user)
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

    describe "#rename_tag" do
      it "should find the tag by its name" do
        tag = stub('tag', :name => 'tag7')
        Tagalong::TagalongTag.should_receive(:find_by_name).with('tag7').and_return(tag)
        Tagalong::TagalongTag.stub(:find_by_name).with('renamedTag7').and_return(false)
        tag.stub(:update_attribute)
        @user.rename_tag('tag7', 'renamedTag7')
      end

      it "should not save the tag if the Tagger doesn't own it" do
        Tagalong::TagalongTag.stub(:find_by_name).and_return(false)
        lambda { @user.rename_tag('tag7', 'renamedTag7') }.should raise_error(Tagalong::TagNotFound)
      end

      it "should save the tag if the Tagger owns it" do
        tag9 = mock('tag 9', :name => 'tag9')
        Tagalong::TagalongTag.stub(:find_by_name).with('tag9').and_return(tag9)
        Tagalong::TagalongTag.stub(:find_by_name).with('renamedTag9').and_return(false)
        tag9.should_receive(:update_attribute).with(:name, 'renamedTag9')
        @user.rename_tag('tag9', 'renamedTag9')
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
