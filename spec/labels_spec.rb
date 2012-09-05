require 'pebbles-uid/conditions'
require 'pebbles-uid/labels'

describe Pebbles::Uid::Labels do

  subject { Pebbles::Uid::Labels.new('a.b.c') }
  its(:to_s) { should eq('a.b.c') }
  its(:to_a) { should eq(%w(a b c)) }
  its(:to_hash) {  should eq('label_0' => "a", 'label_1' => "b", 'label_2' => "c") }

  it "delegates to conditions" do
    subject.to_hash(:name => 'thing', :verbose => false).should eq({'thing' => 'a.b.c'})
  end

end
