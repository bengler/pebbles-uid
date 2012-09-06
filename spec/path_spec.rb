require 'pebbles-uid/conditions'
require 'pebbles-uid/labels'
require 'pebbles-uid/path'

describe Pebbles::Uid::Path do

  subject { Pebbles::Uid::Path.new('magical', 'forrest', 'clearing') }

  its(:realm) { should eq('magical') }
  its(:to_s) { should eq('magical.forrest.clearing') }
  its(:to_a) { should eq(%w(magical forrest clearing)) }
  its(:to_hash) { should eq({'path_0' => 'magical', 'path_1' => 'forrest', 'path_2' => 'clearing'}) }
  its(:valid?) { should be_true }

  it "can customize the hash" do
    subject.to_hash(:name => 'label').should eq({'label_0' => 'magical', 'label_1' => 'forrest', 'label_2' => 'clearing'})
  end

  specify { Pebbles::Uid::Path.new("abc123").should be_valid }
  specify { Pebbles::Uid::Path.new("abc.123").should be_valid }
  specify { Pebbles::Uid::Path.new("abc.de-f.123").should be_valid }

  specify { Pebbles::Uid::Path.new("").should_not be_valid }
  specify { Pebbles::Uid::Path.new(".").should_not be_valid }
  specify { Pebbles::Uid::Path.new("..").should_not be_valid }
  specify { Pebbles::Uid::Path.new("abc!").should_not be_valid }
  specify { Pebbles::Uid::Path.new("ab. 123").should_not be_valid }

end
