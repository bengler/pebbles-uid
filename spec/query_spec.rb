require 'pebbles-uid'

describe Pebbles::Uid::Query do

  it "no longer accepts a list of specific uids" do
    pending "how do we want to do this?"
    Pebbles::Uid::Query.new('a:b$1,a:c$2').valid?.should == false
  end

  context "everything" do
    subject { Pebbles::Uid::Query.new('*:*') }

    its(:species?) { should == false }
    its(:path?) { should == false }
    its(:oid?) { should == false }

    its(:specific?) { should == false }
  end

  context "everything, with any oid" do
    subject { Pebbles::Uid::Query.new('*:*$*') }

    its(:species?) { should == false }
    its(:path?) { should == false }
    its(:oid?) { should == false }

    its(:specific?) { should == false }
  end

  context "a comma-separated list" do
    it "takes constrained uids" do
      ->{ Pebbles::Uid::Query.new('a:b$1,b:c$2') }.should_not raise_error(ArgumentError)
    end

    it "cannot handle a list of wildcard uids" do
      ->{ Pebbles::Uid::Query.new('a:b.*,b:c.*') }.should raise_error(ArgumentError)
    end
  end

  context "a species" do
    subject { Pebbles::Uid::Query.new('beast:*$*') }
    its(:species?) { should == true }
    its(:species) { should eq('beast') }
  end

  context "one oid" do
    subject { Pebbles::Uid::Query.new('*:$yak') }
    its(:oid?) { should == true }
    its(:oid) { should == 'yak' }
  end

  context "several oids" do
    subject { Pebbles::Uid::Query.new('*:$yak|unicorn') }
    its(:oid?) { should == true }
    its(:oid) { should eq('yak|unicorn') }
  end

  context "a path" do
    subject { Pebbles::Uid::Query.new('*:tales.mythical$*') }
    its(:path?) { should == true }
    its(:path) { should == 'tales.mythical' }
  end

  describe "a cache query" do

    it "requires species" do
      Pebbles::Uid::Query.new('*:mythical.4legged$1').try_cache?.should == false
    end

    it "requires realm" do
      Pebbles::Uid::Query.new('monster:*$1').try_cache?.should == false
    end

    it "requires oid" do
      Pebbles::Uid::Query.new('monster:mythical').try_cache?.should == false
      Pebbles::Uid::Query.new('monster:mythical$*').try_cache?.should == false
    end

    it "can take a specific uid" do
      Pebbles::Uid::Query.new('monster:mythical.4legged$1').try_cache?.should == true
    end

    it "can take a wildcard path" do
      Pebbles::Uid::Query.new('monster:mythical.*$1').try_cache?.should == true
    end

    it "can take a list of oids" do
      Pebbles::Uid::Query.new('monster:mythical$1|2').try_cache?.should == true
    end

    it "can take a list of uids" do
      Pebbles::Uid::Query.new('monster:mythical$1,monster:mythical$2').try_cache?.should == true
    end

    it "can take a comma-separated list of uids" do
      uids = 'monster:mythical.beasts$1,monster:mythical.epics$2'
      keys = ['monster:mythical$1', 'monster:mythical$2']
      Pebbles::Uid::Query.new(uids).cache_keys.should eq(keys)
    end

    it "breaks horribly if it can't handle the comma-separated things as uids" do
      uids = 'monster:mythical.*$1,monster:epic.*$2'
      ->{ Pebbles::Uid::Query.new(uids).cache_keys }.should raise_error(ArgumentError)
    end

    it "can handle a wildcard path with a list oids" do
      Pebbles::Uid::Query.new('monster:mythical.*$1|2').try_cache?.should == true
    end

    it "expands and creates cache keys" do
      Pebbles::Uid::Query.new('animal:farm.*$pig|goat').cache_keys.should eq(['animal:farm$pig', 'animal:farm$goat'])
    end

    it "cannot create cache keys if the query is too vague" do
      ->{ Pebbles::Uid::Query.new('*:*').cache_keys }.should raise_error Pebbles::Uid::Query::InvalidCacheQuery
    end

  end
end
