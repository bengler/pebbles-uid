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

  it "can use a suffix on the hash" do
    uid = Pebbles::Uid::Labels.new('a.b.c', :name => 'whatevs', :suffix => 'hey')
    uid.to_hash.should eq(:whatevs_0_hey => 'a', :whatevs_1_hey => 'b', :whatevs_2_hey => 'c')
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

end
