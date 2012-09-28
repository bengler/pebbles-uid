require 'pebbles-uid'

describe Pebbles::Uid do

  let(:uid) { 'post.card:tourism.norway.fjords$1234' }

  describe "extracting single elements" do
    specify { Pebbles::Uid.oid(uid).should eq('1234') }
    specify { Pebbles::Uid.path(uid).should eq('tourism.norway.fjords') }
    specify { Pebbles::Uid.species(uid).should eq('post.card') }

    describe "with missing oid" do
      specify { Pebbles::Uid.oid('post:a.b.c').should eq(nil) }
    end
  end

  describe "query" do
    it "returns a query object" do
      query = Pebbles::Uid.query(uid)
      query.class.should eq(Pebbles::Uid::Query)
      query.to_s.should eq(uid)
    end
  end

  describe "requirements" do
    it "must have a species" do
      ->{ Pebbles::Uid.new(':tourism.norway$1') }.should raise_error(ArgumentError)
    end

    it "must have a realm" do
      ->{ Pebbles::Uid.new('post.card:$1') }.should raise_error(ArgumentError)
    end

    it "can skip the oid" do
      ->{ Pebbles::Uid.new('post.card:tourism.norway') }.should_not raise_error
    end
  end

  subject { Pebbles::Uid.new(uid) }
  its(:to_s) { should eq(uid) }
  its(:parsed) { should eq(['post.card', 'tourism.norway.fjords', '1234']) }

  its(:realm) { should eq('tourism') }
  its(:species) { should eq('post.card') }
  its(:genus) { should eq('card') }
  its(:path) { should eq('tourism.norway.fjords') }
  its(:oid) { should eq('1234') }
  its(:oid?) { should == true }

  its(:cache_key) { should eq('post.card:tourism$1234') }

  context "when pending creation" do

    let(:uid) { 'post.doc:universities.europe.norway' }
    subject { Pebbles::Uid.new(uid) }

    its(:to_s) { should eq(uid) }
    its(:parsed) { should eq(['post.doc', 'universities.europe.norway']) }
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

  context "species" do
    %w(- . _ 8).each do |char|
      it "accepts #{char} in a species" do
        Pebbles::Uid.new("uni#{char}corn:mythical$1").valid_species?.should == true
      end
    end

    %w(! % { ? $).each do |char|
      it "rejects #{char}" do
        Pebbles::Uid.new("uni#{char}corn:mythical$1").valid_species?.should == false
      end
    end
  end

  context "oids" do
    it "can be empty" do
      Pebbles::Uid.new("beast:mythical").oid?.should == false
    end

    it "cannot contain pipes" do
      Pebbles::Uid.new("beast:mythical$abc|xyz").valid_oid?.should == false
    end

    it "can be empty" do
      Pebbles::Uid.new("beast:mythical").valid_oid?.should == true
    end

    it "can be an empty string" do
      Pebbles::Uid.new("beast:mythical$").valid_oid?.should == true
    end

    it "is a black box" do
      Pebbles::Uid.new("beast:mythical$holy+%^&*s!").valid_oid?.should == true
    end
  end
end
