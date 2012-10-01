require 'pebbles-uid'

describe Pebbles::Uid do

  let(:uid) { 'post.card:tourism.norway.fjords$1234' }

  describe "extracting single elements" do
    specify { Pebbles::Uid.oid(uid).should eq('1234') }
    specify { Pebbles::Uid.path(uid).should eq('tourism.norway.fjords') }
    specify { Pebbles::Uid.genus(uid).should eq('post.card') }

    describe "with missing oid" do
      specify { Pebbles::Uid.oid('post:a.b.c').should eq(nil) }
    end
  end

  describe "query" do
    it "returns a query object" do
      s = 'post:tourism.*$*'
      Pebbles::Uid::Query.should_receive(:new).with s
      query = Pebbles::Uid.query(s)
    end
  end

  describe "requirements" do
    it "must have a genus" do
      ->{ Pebbles::Uid.new(':tourism.norway$1') }.should raise_error(ArgumentError)
    end

    it "must have a realm" do
      ->{ Pebbles::Uid.new('post:$1') }.should raise_error(ArgumentError)
    end

    it "can skip the oid" do
      ->{ Pebbles::Uid.new('post:tourism') }.should_not raise_error
    end

    it "doesn't accept wildcard genus" do
      ->{ Pebbles::Uid.new('post.*:tourism$1') }.should raise_error(ArgumentError)
      ->{ Pebbles::Uid.new('post|card:tourism$1') }.should raise_error(ArgumentError)
      ->{ Pebbles::Uid.new('post.^b.c:tourism$1') }.should raise_error(ArgumentError)
    end

    it "doesn't accept wildcard paths" do
      ->{ Pebbles::Uid.new('post:tourism.*$1') }.should raise_error(ArgumentError)
      ->{ Pebbles::Uid.new('post:tourism|blogging$1') }.should raise_error(ArgumentError)
      ->{ Pebbles::Uid.new('post:tourism.^b.c$1') }.should raise_error(ArgumentError)
    end

    it "doesn't accept wildcard oid" do
      ->{ Pebbles::Uid.new('post:tourism$*') }.should raise_error(ArgumentError)
    end
  end

  subject { Pebbles::Uid.new(uid) }

  its(:to_s) { should eq(uid) }
  its(:realm) { should eq('tourism') }
  its(:genus) { should eq('post.card') }
  its(:species) { should eq('card') }
  its(:path) { should eq('tourism.norway.fjords') }
  its(:oid) { should eq('1234') }
  its(:oid?) { should == true }

  its(:cache_key) { should eq('post.card:tourism.*$1234') }

  context "when pending creation" do

    let(:uid) { 'post.doc:universities.europe.norway' }
    subject { Pebbles::Uid.new(uid) }

    its(:to_s) { should eq(uid) }
    its(:oid) { should be_nil }

  end

  context "paths" do
    ["abc123", "abc.123", "abc.de-f.123"].each do |path|
      specify "#{path} is a valid path" do
        Pebbles::Uid.valid_path?(path).should == true
      end
    end

    ["", ".", "..", "abc!"].each do |path|
      specify "#{path} is not a valid path" do
        Pebbles::Uid.valid_path?(path).should == false
      end
    end
  end

  context "genus" do
    %w(- . _ 8).each do |char|
      it "accepts #{char} in a genus" do
        Pebbles::Uid.valid_genus?("uni#{char}corn").should == true
      end
    end

    %w(! % { ? $).each do |char|
      it "rejects #{char}" do
        ->{ Pebbles::Uid.new("uni#{char}corn:mythical$1") }.should raise_error(ArgumentError)
      end
    end
  end

  context "oids" do
    it "can be empty" do
      Pebbles::Uid.new("beast:mythical").oid?.should == false
    end

    it "cannot contain pipes" do
      Pebbles::Uid.valid_oid?("abc|xyz").should == false
    end

    it "cannot contain commas, either" do
      Pebbles::Uid.valid_oid?("abc,xyz").should == false
    end

    it "can be empty" do
      Pebbles::Uid.valid_oid?(nil).should == true
    end

    it "can be an empty string" do
      Pebbles::Uid.valid_oid?("").should == true
    end

    it "is a black box" do
      Pebbles::Uid.valid_oid?("holy+%^&*s!").should == true
    end
  end
end
