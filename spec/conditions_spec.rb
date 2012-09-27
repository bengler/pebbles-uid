require 'pebbles-uid/conditions'

describe Pebbles::Uid::Conditions do

  subject { Pebbles::Uid::Conditions.new(%w(a b c)) }

  its(:to_hash) { should eq('label_0' => "a", 'label_1' => "b", 'label_2' => "c") }

  describe "customized labels" do
    subject { Pebbles::Uid::Conditions.new(%w(p r q), :name => 'dot', :suffix => '') }
    its(:to_hash) { should eq('dot_0_' => 'p', 'dot_1_' => 'r', 'dot_2_' => 'q') }
  end

  it "has a non-verbose mode" do
    uid = Pebbles::Uid::Conditions.new(%w(k l m), :name => 'stuff', :verbose => false)
    uid.to_hash.should eq({'stuff' => 'k.l.m'})
  end

  specify "non-verbose still takes a suffix" do
    uid = Pebbles::Uid::Conditions.new(%w(k l m), :name => 'stuff', :verbose => false, :suffix => 'xyz')
    uid.to_hash.should eq({'stuff_xyz' => 'k.l.m'})
  end

  describe "with a stop label" do
    subject { Pebbles::Uid::Conditions.new(%w(x y z), :stop => nil) }
    its(:to_hash) {  should eq('label_0' => "x", 'label_1' => "y", 'label_2' => "z", 'label_3' => nil) }
  end

  describe "next label" do
    subject { Pebbles::Uid::Conditions.new(%w(h j k l), :name => 'vim') }
    its(:next) { should eq('vim_4') }
  end

  describe "with pipes" do
    subject { Pebbles::Uid::Conditions.new(%w(a b|c d), :stop => nil) }
    its(:to_hash) {  should eq('label_0' => "a", 'label_1' => ['b', 'c'], 'label_2' => "d", 'label_3' => nil) }
  end

  describe "with an asterisk" do
    # ignores stop marker if it is terminated by an asterisk
    subject { Pebbles::Uid::Conditions.new(%w(a b *), :stop => nil) }
    its(:to_hash) {  should eq('label_0' => "a", 'label_1' => 'b') }
  end

  describe "with an asterisk" do
    subject { Pebbles::Uid::Conditions.new(%w(a ^b c), :stop => nil) }
    its(:to_hash) {  should eq('label_0' => "a", 'label_1' => ['b', nil], 'label_2' => ['c', nil], 'label_3' => nil) }
  end

  describe "complicated stuff" do
    subject { Pebbles::Uid::Conditions.new(%w(a ^b|c d *), :stop => nil) }
    its(:to_hash) {  should eq('label_0' => "a", 'label_1' => ['b', 'c', nil], 'label_2' => ['d', nil]) }
  end

end
