require 'pebbles-uid'

describe Pebbles::Uid::Query do

  context "for a single resource" do
    let(:term) { "post:area51$abc" }
    subject { Pebbles::Uid::Query.new(term) }

    its(:term) { should == term }

    its(:for_one?) { should == true }
    its(:list?) { should == false }
    its(:collection?) { should == false }

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
  end

  context "for a list of resources" do
    let(:term) { "post:area51$abc,post:area51$xyz" }
    subject { Pebbles::Uid::Query.new(term) }

    its(:for_one?) { should == false }
    its(:list?) { should == true }
    its(:collection?) { should == false }

    it "handles a pipe-delimited list of oids" do
      query = Pebbles::Uid::Query.new("post:area51$abc|xyz")
      query.terms.should eq(['post:area51$abc', 'post:area51$xyz'])
    end

    it "ignores crazy wildcard stuff in the path" do
      query = Pebbles::Uid::Query.new("post:area51.^a.b.c.*|d$abc|xyz")
      query.list?.should == true
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
    end

    context "everything, with any oid" do
      subject { Pebbles::Uid::Query.new('*:*$*') }

      its(:species?) { should == false }
      its(:path?) { should == false }
      its(:oid?) { should == false }
    end

    context "a species" do
      subject { Pebbles::Uid::Query.new('beast:*$*') }
      its(:species?) { should == true }
      its(:species) { should eq('beast') }
    end

    context "a genus" do
      subject { Pebbles::Uid::Query.new('beast.mythical.hairy:*$*') }
      its(:genus?) { should == true }
      its(:genus) { should eq('mythical.hairy') }
    end

    context "a path" do
      subject { Pebbles::Uid::Query.new('*:area51.*') }
      its(:path?) { should == true }
    end

    context "one oid" do
      subject { Pebbles::Uid::Query.new('*:*$yak') }
      its(:oid?) { should == true }
      its(:oid) { should == 'yak' }
    end

  end

end
