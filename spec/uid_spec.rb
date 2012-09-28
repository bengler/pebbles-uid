require 'pebbles-uid'

describe Pebbles::Uid do

  let(:uid) { 'post.card:tourism.norway.fjords$1234' }

  subject { Pebbles::Uid.new(uid) }
  its(:to_s) { should eq(uid) }
  its(:parsed) { should eq(['post.card', 'tourism.norway.fjords', '1234']) }

  its(:realm) { should eq('tourism') }
  its(:species) { should eq('post.card') }
  its(:genus) { should eq('card') }
  its(:path) { should eq('tourism.norway.fjords') }
  its(:oid) { should eq('1234') }

  its(:cache_key) { should eq('post.card:*$1234') }

  its(:valid?) { should be_true }

  describe "extracting single elements" do
    specify { Pebbles::Uid.oid(uid).should eq('1234') }
    specify { Pebbles::Uid.path(uid).should eq('tourism.norway.fjords') }
    specify { Pebbles::Uid.species(uid).should eq('post.card') }
  end

  specify ":to_hash creates reasonable query params (e.g. for active record)" do
    expected = {
      'species' => 'post.card',
      'path_0' => 'tourism',
      'path_1' => 'norway',
      'path_2' => 'fjords',
      'oid' => '1234'
    }
    subject.to_hash.should eq(expected)
  end

  specify ":to_hash has overrides to make indexable params (e.g. for elastic search)" do
    expected = {
      'species_0_' => 'post',
      'species_1_' => 'card',
      'path_0_' => 'tourism',
      'path_1_' => 'norway',
      'path_2_' => 'fjords',
      'oid_' => '1234'
    }
    subject.to_hash(:verbose => true, :suffix => '').should eq(expected)
  end

  specify ":to_hash overrides can get totally ridiculous" do
    expected = {
      'klass_0_xyz' => 'post',
      'klass_1_xyz' => 'card',
      'label_0_xyz' => 'tourism',
      'label_1_xyz' => 'norway',
      'label_2_xyz' => 'fjords',
      'id_xyz' => '1234'
    }
    subject.to_hash(:verbose => true, :suffix => 'xyz', :species => 'klass', :path => 'label', :oid => 'id').should eq(expected)
  end

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
        Pebbles::Uid.new("beast:#{path}$1").valid_path?.should == true
      end
    end

    ["", ".", "..", "abc!"].each do |path|
      specify "#{path} is not a valid path" do
        Pebbles::Uid.new("beast:#{path}$1").valid_path?.should == false
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
      Pebbles::Uid.new("beast:mythical").valid_oid?.should == true
    end

    it "can be an empty string" do
      Pebbles::Uid.new("beast:mythical$").valid_oid?.should == true
    end

    it "is a black box" do
      Pebbles::Uid.new("beast:mythical$holy+%^&*s!").valid_oid?.should == true
    end
  end

  context "wildcard" do
    it "doesn't allow wildcard species" do
      ->{ Pebbles::Uid.new("*:mythical$1") }.should raise_error(Pebbles::Uid::WildcardUidError)
    end
  end
end
