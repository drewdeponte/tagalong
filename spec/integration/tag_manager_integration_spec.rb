require 'spec_helper'

describe "TagManager Integration" do
  before(:each) do
    @contact = Contact.create!(:name => "Bob Bobster")
    @user = User.create!(:name => "My User")
    @contact_tag_manager = Tagalong::TagManager.new(@contact, @user)
  end

  describe "#add_tag" do
    it "add new tag to contact" do
      @contact_tag_manager.add_tag("fool")
      @contact.tagalong_tags.map { |r| r.name }.should include("fool")
    end

    it "add an existing tag to contact" do
      @contact_tag_manager.add_tag("bar")
      @contact_tag_manager.add_tag("bar")
    end
  end

  describe "#remove_tag" do
    it "remove tag from contact" do
      cm_contact_tag = @user.tagalong_tags.create!(:name => "crazy")
      @contact.tagalong_taggings.create!(:tagalong_tag_id => cm_contact_tag.id)
      @contact_tag_manager.remove_tag("crazy")
      @contact.tagalong_tags.map { |r| r.name }.should_not include("crazy")
    end
  end

  describe "#owners_tags" do
    it "list managed owners tags in order of most to least referenced" do
      Tagalong::TagalongTag.create!(:owner_id => @user.id, :name => "kitty", :number_of_references => 20)
      Tagalong::TagalongTag.create!(:owner_id => @user.id, :name => "bar", :number_of_references => 5)
      Tagalong::TagalongTag.create!(:owner_id => @user.id, :name => "foo", :number_of_references => 10)
      @contact_tag_manager.owners_tags.should == ["kitty", "foo", "bar"]
    end
  end

  describe "full usage including multiple references to tags" do
    it "properly adds tags and tracks tag reference counts and orders tag list based on reference counts properly" do
      contact2 = Contact.create!(:name => "Bob Boogy")
      contact3 = Contact.create!(:name => "Brice Torez")
      tag_manager2 = Tagalong::TagManager.new(contact2, @user)
      tag_manager3 = Tagalong::TagManager.new(contact3, @user)
      @contact_tag_manager.add_tag("bar")
      tag_manager2.add_tag("bar")
      @contact_tag_manager.add_tag("car")
      @contact_tag_manager.add_tag("foo")
      tag_manager2.add_tag("foo")
      tag_manager3.add_tag("foo")
      @contact_tag_manager.owners_tags.should == ["foo", "bar", "car"]
    end
  end
end
