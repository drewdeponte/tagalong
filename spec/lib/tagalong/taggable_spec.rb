require 'spec_helper'

# The Contact class which is used in this as our taggable model
# is defined in the spec/models.rb file.

describe "Taggable" do
  before(:each) do
    @user = User.create!(:name => "My Owner")
    @contact = Contact.create!(:name => "My Taggable")
  end

  describe "Integration" do
    describe "#tagged_with?" do
      it "returns true if the taggable has the given tag" do
        tag = @user.tagalong_tags.create!(:name => "foo")
        @contact.tagalong_taggings.create!(:tagalong_tag_id => tag.id)
        @contact.tagged_with?("foo").should be_true
      end
      
      it "returns false if the taggable does NOT have the given tag" do
        @contact.tagged_with?("bar").should be_false
      end
    end

    describe "#tags" do
      it "returns list of tags currently applied to this taggable" do
        @contact.tagalong_tags.create!(:name => "foo")
        @contact.tagalong_tags.create!(:name => "bar")
        @contact.tagalong_tags.create!(:name => "car")
        @contact.tags.should == ["bar", "car", "foo"]
      end

      it "returns list of tags currently applied in descending order of references" do
        @contact.tagalong_tags.create!(:name => "hoopty", :number_of_references => 5)
        @contact.tagalong_tags.create!(:name => "doopty", :number_of_references => 99)
        @contact.tagalong_tags.create!(:name => "toopty", :number_of_references => 4)
        @contact.tags.should == ["doopty", "hoopty", "toopty"]
      end
    end
  end

  describe "Isolation" do
  end
end
