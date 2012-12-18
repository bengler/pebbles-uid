require 'pebbles-uid'

describe Pebbles::Uid::Query do

  context "for a single resource" do
    let(:term) { "post.doc:area51$abc" }
    subject { Pebbles::Uid::Query.new(term, :suffix => '') }

    its(:term) { should == term }

    its(:for_one?) { should == true }
    its(:list?) { should == false }
    its(:collection?) { should == false }
    its(:cache_keys) { should eq(['post.doc:area51.*$abc']) }
    its(:to_hash) { should eq(:species_0_ => 'post', :species_1_ => 'doc', :path_0_ => 'area51', :oid_ => 'abc') }
    its(:genus) { should == 'post' }
    its(:species) { should == 'post.doc' }
    its(:path) { should == 'area51' }
    its(:oid) { should == 'abc' }

    it "handles a wildcard path if realm is given" do
      query = Pebbles::Uid::Query.new('post:area51.*$abc')
      query.for_one?.should == true
    end

    it "ignores crazy wildcard stuff in the path" do
      query = Pebbles::Uid::Query.new("post:area51.^a.b.c.*|d$abc")
      query.for_one?.should == true
    end

    it "bails without realm" do
      ->{ Pebbles::Uid::Query.new('post:*$abc') }.should raise_error(ArgumentError)
      ->{ Pebbles::Uid::Query.new('post:$abc') }.should raise_error(ArgumentError)
    end

    it "doesn't have a list of uids" do
      ->{ subject.list }.should raise_error StandardError
    end
  end

  context "for a list of resources" do
    let(:term) { "post.doc:area51$abc,post.doc:area51$xyz" }
    subject { Pebbles::Uid::Query.new(term) }

    its(:for_one?) { should == false }
    its(:list?) { should == true }
    its(:collection?) { should == false }
    its(:genus) { should == 'post' }

    its(:cache_keys) { should eq(['post.doc:area51.*$abc', 'post.doc:area51.*$xyz']) }

    it "only accepts one single genus"

    context "by oid" do
      subject { Pebbles::Uid::Query.new("post:area51$abc|xyz") }

      its(:list) { should eq(['post:area51$abc', 'post:area51$xyz']) }

      it "can't do hashes under these circumstances" do
        ->{ subject.to_hash }.should raise_error(RuntimeError)
      end
    end

    it "ignores crazy wildcard stuff in the path" do
      query = Pebbles::Uid::Query.new("post:area51.^a.b.c.*|d$abc|xyz")
      query.list?.should == true
      query.cache_keys.should eq(['post:area51.*$abc', 'post:area51.*$xyz'])
    end

    it "bails without realm" do
      ->{ Pebbles::Uid::Query.new('post:*$abc,post:*$xyz') }.should raise_error(ArgumentError)
    end

    it "must have only one realm" do
      ->{ Pebbles::Uid::Query.new('post:area51$abc,post:area52$xyz') }.should raise_error(ArgumentError)
    end

    it "bails with unspecific species" do
      ->{ Pebbles::Uid::Query.new('post.*:area51$abc,post:area51$xyz') }.should raise_error(ArgumentError)
    end

    it "bails with unspecified oid" do
      ->{ Pebbles::Uid::Query.new('post:area51$*,post:area51$xyz') }.should raise_error(ArgumentError)
    end
  end

  context "for a list of resources, with one entry, but tailing comma - indicating a list" do
    let(:term) { "post.doc:area51$abc," }
    subject { Pebbles::Uid::Query.new(term) }

    its(:for_one?) { should == false }
    its(:list?) { should == true }
  end

  context "for a collection of resources" do
    let(:term) { "post.*:area51.^a.b.c" }
    subject { Pebbles::Uid::Query.new(term) }

    its(:for_one?) { should == false }
    its(:list?) { should == false }
    its(:collection?) { should == true }

    it "handles unspecific oids" do
      Pebbles::Uid::Query.new('post:area51$*').collection?.should == true
      Pebbles::Uid::Query.new('post:area51').collection?.should == true
    end
  end

  describe "wildcard queries" do

    context "everything" do
      subject { Pebbles::Uid::Query.new('*:*') }

      its(:species?) { should == false }
      its(:path?) { should == false }
      its(:oid?) { should == false }

      its(:to_hash) { should == {} }

      it "doesn't have a list of uids" do
        ->{ subject.list }.should raise_error StandardError
      end
    end

    context "everything, with any oid" do
      subject { Pebbles::Uid::Query.new('*:*$*') }

      its(:species?) { should == false }
      its(:path?) { should == false }
      its(:oid?) { should == false }
      its(:to_hash) { should == {} }
    end

    context "a species" do
      subject { Pebbles::Uid::Query.new('beast:*$*') }
      its(:species?) { should == true }
      its(:species) { should eq('beast') }
      its(:epiteth?) { should == false }
      its(:to_hash) { should == {:species_0 => 'beast'} }
    end

    context "a epiteth" do
      subject { Pebbles::Uid::Query.new('beast.mythical.hairy:*$*') }
      its(:epiteth?) { should == true }
      its(:epiteth) { should eq('mythical.hairy') }
      its(:to_hash) { should == {:species_0 => 'beast', :species_1 => 'mythical', :species_2 => 'hairy'} }
    end

    context "a path" do
      subject { Pebbles::Uid::Query.new('*:area51.*') }
      its(:path?) { should == true }
      its(:to_hash) { should == {:path_0 => 'area51'} }
    end

    context "one oid" do
      subject { Pebbles::Uid::Query.new('*:*$yak') }
      its(:oid?) { should == true }
      its(:oid) { should == 'yak' }
      its(:to_hash) { should == {:oid => 'yak'} }
    end

    context "a typical search" do
      subject { Pebbles::Uid::Query.new('beast:myths.*', :species => 'klass', :path => 'label', :suffix => '') }
      its(:to_hash) { should == {:klass_0_ => 'beast', :label_0_ => 'myths'} }
      its(:next_path_label) { should == :label_1_ }
    end

    context "with a wildcard path" do
      subject { Pebbles::Uid::Query.new('beast:myths.scary') }
      its(:for_one?) { should == false }
      its(:collection?) { should == true }
    end

    context "a search with stops" do
      subject { Pebbles::Uid::Query.new('beast:myths$*', :species => 'klass', :path => 'label', :suffix => '', :stop => nil) }
      its(:to_hash) { should == {:klass_0_ => 'beast', :klass_1_ => nil, :label_0_ => 'myths', :label_1_ => nil} }
      its(:next_path_label) { should == :label_1_ }
    end
  end

end
