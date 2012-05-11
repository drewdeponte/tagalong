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
end
