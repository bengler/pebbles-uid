require 'pebbles-uid/labels'
require 'pebbles-uid/oid'

describe Pebbles::Uid::Oid do

  describe "wildcard" do
    specify { Pebbles::Uid::Oid.new('*').wildcard?.should == true }
    specify { Pebbles::Uid::Oid.new('star*star').wildcard?.should == false }
    specify { Pebbles::Uid::Oid.new('abc|xyz').wildcard?.should == true }
  end

end
