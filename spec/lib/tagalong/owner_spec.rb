require 'spec_helper'

# The User class which is used in this as our owner model
# is defined in the spec/models.rb file.

describe "Owner Integration" do
  before(:each) do
    @user = User.create!(:name => "My Owner")
    @contact = Contact.create!(:name => "My Taggable")
  end

  describe "#tag" do
    it "tags the given taggable object with the given tag name" do
      @user.tag(@contact, "foo")
      @contact.tagalong_tags.map { |r| r.name }.should include("foo")
    end
  end

  describe "#untag" do
    it "untags the given taggable object from the given tag name" do
      @contact.tagalong_tags.create!(:owner_id => @user.id, :owner_type => 'User', :name => "bar")
      @user.untag(@contact, "bar")
      @contact.tagalong_tags.map { |r| r.name }.should_not include("bar")
    end
  end

  describe "#tags" do
  end
end
