require 'spec_helper'

# The Contact class which is used in this as our taggable model
# is defined in the spec/models.rb file.

describe "Taggable Integration" do
  describe "#add_tag" do
    context "tag does NOT exist" do
      it "creates the new tag and associates it to the taggable model" do
        c = Contact.create!(:name => "Bob Villa")
        c.add_tag("foo")
        c.tagalong_tags.map { |r| r.name }.should include("foo")
      end
    end

    context "tag already exists, but is not associated" do
      it "does NOT create a new tag"
      it "associates the matching exsiting tag to the taggable model"
    end

    context "tag already exists & is already associated" do
      it "does NOT create a new tag"
      it "does NOT associate the existintg tag to the taggable model"
    end
  end
end
