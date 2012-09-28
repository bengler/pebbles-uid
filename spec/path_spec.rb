require 'pebbles-uid/conditions'
require 'pebbles-uid/labels'
require 'pebbles-uid/path'

describe Pebbles::Uid::Path do

  subject { Pebbles::Uid::Path.new('magical', 'forrest', 'clearing') }

  its(:realm) { should eq('magical') }
  its(:realm?) { should == true }
  its(:to_s) { should eq('magical.forrest.clearing') }
  its(:to_a) { should eq(%w(magical forrest clearing)) }
  its(:to_hash) { should eq({'path_0' => 'magical', 'path_1' => 'forrest', 'path_2' => 'clearing'}) }
  its(:wildcard?) { should == false }

  it "can customize the hash" do
    subject.to_hash(:name => 'label').should eq({'label_0' => 'magical', 'label_1' => 'forrest', 'label_2' => 'clearing'})
  end

  specify "wildcard realm" do
    Pebbles::Uid::Path.new('*').realm?.should == false
  end

end
