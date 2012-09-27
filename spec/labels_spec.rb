require 'pebbles-uid/conditions'
require 'pebbles-uid/labels'

describe Pebbles::Uid::Labels do

  subject { Pebbles::Uid::Labels.new('a.b.c') }
  its(:to_s) { should eq('a.b.c') }
  its(:to_a) { should eq(%w(a b c)) }
  its(:to_hash) {  should eq('label_0' => "a", 'label_1' => "b", 'label_2' => "c") }
  its(:tail) { should eq(%w(b c)) }

  it "delegates to conditions" do
    subject.to_hash(:name => 'thing', :verbose => false).should eq({'thing' => 'a.b.c'})
  end

  it "has a size" do
    subject.size.should eq(3)
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


end
