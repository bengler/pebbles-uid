require 'pebbles-uid'

describe Pebbles::Uid do

  let(:uid) { 'post.card:tourism.norway.fjords$1234' }

  describe "query" do
    it "returns a query object" do
      s = 'post:tourism.*$*'
      Pebbles::Uid::Query.should_receive(:new).with s, {}
      query = Pebbles::Uid.query(s)
    end
  end

  describe "extracts" do
    specify "genus" do
      Pebbles::Uid.genus(uid).should eq('post')
    end

    specify "species" do
      Pebbles::Uid.species(uid).should eq('post.card')
    end

    specify "epiteth" do
      Pebbles::Uid.epiteth('post.picture.card:a.b.c$1').should eq('picture.card')
    end

    specify "path" do
      Pebbles::Uid.path(uid).should eq('tourism.norway.fjords')
    end

    specify "oid" do
      Pebbles::Uid.oid(uid).should eq('1234')
    end

    describe "when oid is non-existant" do
      it "returns nil oid" do
        Pebbles::Uid.oid('post:a.b.c').should be_nil
      end
    end

    describe "when oid is empty" do
      it "returns nil oid" do
        Pebbles::Uid.oid('post:a.b.c$').should be_nil
      end
    end

    describe "when uid is invalid" do
      it "returns nil oid" do
        Pebbles::Uid.oid('1').should be_nil
      end
    end
  end

  describe "must" do
    specify "have a species" do
      ->{ Pebbles::Uid.new(':tourism.norway$1') }.should raise_error(ArgumentError)
    end

    specify "have a realm" do
      ->{ Pebbles::Uid.new('post:$1') }.should raise_error(ArgumentError)
    end
  end

  describe "may" do
    specify "have no oid" do
      ->{ Pebbles::Uid.new('post:tourism') }.should_not raise_error
    end
  end

  describe "rejects" do
    it "wildcard species" do
      ->{ Pebbles::Uid.new('post.*:tourism$1') }.should raise_error(ArgumentError)
      ->{ Pebbles::Uid.new('post|card:tourism$1') }.should raise_error(ArgumentError)
      ->{ Pebbles::Uid.new('post.^b.c:tourism$1') }.should raise_error(ArgumentError)
    end

    it "wildcard paths" do
      ->{ Pebbles::Uid.new('post:tourism.*$1') }.should raise_error(ArgumentError)
      ->{ Pebbles::Uid.new('post:tourism|blogging$1') }.should raise_error(ArgumentError)
      ->{ Pebbles::Uid.new('post:tourism.^b.c$1') }.should raise_error(ArgumentError)
    end

    it "wildcard oid" do
      ->{ Pebbles::Uid.new('post:tourism$*') }.should raise_error(ArgumentError)
    end
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
        Pebbles::Uid.valid_species?("uni#{char}corn").should == true
      end
    end

    %w(! % { ? $).each do |char|
      it "rejects #{char}" do
        ->{ Pebbles::Uid.new("uni#{char}corn:mythical$1") }.should raise_error(ArgumentError)
      end
    end
  end

  context "oids" do

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

  describe "A Uid" do
    subject { Pebbles::Uid.new(uid) }

    its(:to_s) { should eq(uid) }
    its(:realm) { should eq('tourism') }
    its(:genus) { should eq('post') }
    its(:species) { should eq('post.card') }
    its(:epiteth) { should eq('card') }
    its(:path) { should eq('tourism.norway.fjords') }
    its(:oid) { should eq('1234') }
    its(:oid?) { should == true }
    its(:parent) { should eq('post.card:tourism.norway$fjords') }
    it "has a parent with a different species" do
      subject.parent('stuff').should eq('stuff:tourism.norway$fjords')
    end

    its(:child_path) { should eq('tourism.norway.fjords.1234') }

    its(:children) { should eq('*:tourism.norway.fjords.1234')}
    it "has children of a certain species" do
      subject.children('stuff').should eq('stuff:tourism.norway.fjords.1234')
    end

    its(:cache_key) { should eq('post.card:tourism.*$1234') }

    its(:to_hash) do
      should eq(:species_0 => 'post', :species_1 => 'card', :path_0 => 'tourism', :path_1 => 'norway', :path_2 => 'fjords', :oid => '1234')
    end

    context "without an oid" do
      it "excludes the oid key from the hash" do
        Pebbles::Uid.new('post.doc:a.b.c').to_hash.should eq(:species_0 => 'post', :species_1 => 'doc', :path_0 => 'a', :path_1 => 'b', :path_2 => 'c')
      end
    end

    context "when pending creation" do

      let(:uid) { 'post.doc:universities.europe.norway' }
      subject { Pebbles::Uid.new(uid) }

      its(:to_s) { should eq(uid) }
      its(:oid) { should be_nil }

    end
  end
end
