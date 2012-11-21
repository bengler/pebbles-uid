require 'pebbles-uid/conditions'
require 'pebbles-uid/labels'

describe Pebbles::Uid::Labels do

  subject { Pebbles::Uid::Labels.new('a.b.c', :name => 'thing') }
  its(:to_s) { should eq('a.b.c') }
  its(:to_a) { should eq(%w(a b c)) }
  its(:to_hash) {  should eq(:thing_0 => "a", :thing_1 => "b", :thing_2 => "c") }
  its(:tail) { should eq(%w(b c)) }

  it "has a size" do
    subject.size.should eq(3)
  end

  it "knows the next label" do
    subject.next_label.should eq(:thing_3)
  end

  it "can use a suffix on the hash" do
    uid = Pebbles::Uid::Labels.new('a.b.c', :name => 'whatevs', :suffix => 'hey')
    uid.to_hash.should eq(:whatevs_0_hey => 'a', :whatevs_1_hey => 'b', :whatevs_2_hey => 'c')
  end

  it "handles max-depth" do
    uid = Pebbles::Uid::Labels.new('a.b.c', :name => 'label', :stop => 'HALT', :max_depth => 3)
    uid.to_hash.should eq(:label_0 => 'a', :label_1 => 'b', :label_2 => 'c')
  end

  describe "alternate constructors" do
    it { Pebbles::Uid::Labels.new('a', 'b', 'c').to_s.should eq('a.b.c') }
    it { Pebbles::Uid::Labels.new(['a', 'b', 'c']).to_s.should eq('a.b.c') }
  end

  # Not certain where I want to deal with invalid wildcard paths yet.
  context "wildcards" do
    specify { Pebbles::Uid::Labels.new('a.*').wildcard?.should == true }
    specify { Pebbles::Uid::Labels.new('a.b|c').wildcard?.should == true }
    specify { Pebbles::Uid::Labels.new('a.^b.c').wildcard?.should == true }
  end

  context "validation" do
    it { subject.valid_with?(/[0-9]/).should == false }
    it { subject.valid_with?(/[a-z]/).should == true }
  end

  context "parent_of?" do
    let(:a) { Pebbles::Uid::Labels.new('a') }
    let(:a_b_c) { Pebbles::Uid::Labels.new('a.b.c') }
    let(:a_b_d) { Pebbles::Uid::Labels.new('a.b.d') }

    specify { a.parent_of?(a).should == false }
    specify { a_b_c.parent_of?(a).should == false }
    specify { a.parent_of?(a_b_c).should == true }
    specify { a_b_c.parent_of?(a_b_d).should == false }
  end

  context "#child_of?" do
    let(:a) { Pebbles::Uid::Labels.new('a') }
    let(:b) { Pebbles::Uid::Labels.new('b') }
    let(:a_b) { Pebbles::Uid::Labels.new('a.b') }

    specify { a.child_of?(a).should == false }
    specify { a_b.child_of?(a).should == true }
    specify { a.child_of?(b).should == false }
    specify { a.child_of?(a_b).should == false }
  end

end
