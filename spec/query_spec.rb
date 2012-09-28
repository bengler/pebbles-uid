require 'pebbles-uid'

describe Pebbles::Uid::Query do

  context "everything" do
    subject { Pebbles::Uid::Query.new('*:*') }

    its(:species?) { should == false }
    its(:path?) { should == false }
    its(:oid?) { should == false }

    its(:specific?) { should == false }
  end

  context "everything, with any oid" do
    subject { Pebbles::Uid::Query.new('*:*$*') }

    its(:species?) { should == false }
    its(:path?) { should == false }
    its(:oid?) { should == false }

    its(:specific?) { should == false }
  end

  context "a species" do
    subject { Pebbles::Uid::Query.new('beast:*$*') }
    its(:species?) { should == true }
  end

  context "one oid" do
    subject { Pebbles::Uid::Query.new('*:$yak') }
    its(:oid?) { should == true }
  end

  context "several oids" do
    subject { Pebbles::Uid::Query.new('*:$yak|unicorn') }
    its(:oid?) { should == true }
  end

  specify { Pebbles::Uid::Query.new('*:tales.mythical$*').path?.should == true }

end
