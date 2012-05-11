require 'spec_helper'

# The Contact class which is used in this as our taggable model
# is defined in the spec/models.rb file.

describe "Taggable" do
  before(:each) do
    @user = User.create!(:name => "My Owner")
    @contact = Contact.create!(:name => "My Taggable")
  end

  describe "Integration" do
    describe "#has_tag?" do
      it "returns true if the taggable has the given tag" do
        tag = @user.tagalong_tags.create!(:name => "foo")
        @contact.tagalong_taggings.create!(:tagalong_tag_id => tag.id)
        @contact.has_tag?("foo").should be_true
      end
      
      it "returns false if the taggable does NOT have the given tag" do
        @contact.has_tag?("bar").should be_false
      end
    end

    describe "#tags" do
      it "returns list of tags currently applied to this taggable" do
        @contact.tagalong_tags.create!(:name => "foo")
        @contact.tagalong_tags.create!(:name => "bar")
        @contact.tagalong_tags.create!(:name => "car")
        @contact.tags.should == ["foo", "bar", "car"]
      end
    end
  end

  describe "Isolation" do
  end
end
