require 'spec_helper'

describe "Tagalong Sunspot Support" do
  describe "#enable_sunspot" do
    it "registers ActiveRecord instance adapter" do
      Sunspot::Adapters::DataAccessor.stub(:register)
      Sunspot.stub(:setup)
      Sunspot::Adapters::InstanceAdapter.should_receive(:register).with(Sunspot::Rails::Adapters::ActiveRecordInstanceAdapter, ActiveRecord::Base)
      Tagalong.enable_sunspot
    end

    it "registers ActiveRecord data adapter"  do
      Sunspot::Adapters::InstanceAdapter.stub(:register)
      Sunspot.stub(:setup)
      Sunspot::Adapters::DataAccessor.should_receive(:register).with(Sunspot::Rails::Adapters::ActiveRecordDataAccessor, ActiveRecord::Base)
      Tagalong.enable_sunspot
    end
    
    it "sets up indexing of the Tagalong::TagalongTag by sunspot" do
      Sunspot::Adapters::InstanceAdapter.stub(:register)
      Sunspot::Adapters::DataAccessor.stub(:register)
      Sunspot.should_receive(:setup).with(Tagalong::TagalongTag)
      Tagalong.enable_sunspot
    end
  end

  describe "#sunspot_enabled" do
    it "return false if #enable_sunspot has NOT previously been called" do
      Tagalong::TagalongTag.stub(:searchable?).and_return(false)
      Tagalong.sunspot_enabled?.should be_false
    end

    it "returns true if #enable_sunspot has previously been called" do
      Tagalong.enable_sunspot
      Tagalong.sunspot_enabled?.should be_true
    end
  end

  describe "#reindex_sunspot" do
    it "reindexes the Sunspot solr index for the supported models" do
      Tagalong::TagalongTag.should_receive(:reindex)
      Tagalong.reindex_sunspot
    end
  end
end
