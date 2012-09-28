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
    its(:species) { should eq('beast') }
  end

  context "one oid" do
    subject { Pebbles::Uid::Query.new('*:$yak') }
    its(:oid?) { should == true }
    its(:oid) { should == 'yak' }
  end

  context "several oids" do
    subject { Pebbles::Uid::Query.new('*:$yak|unicorn') }
    its(:oid?) { should == true }
    its(:oid) { should eq('yak|unicorn') }
  end

  context "a path" do
    subject { Pebbles::Uid::Query.new('*:tales.mythical$*') }
    its(:path?) { should == true }
    its(:path) { should == 'tales.mythical' }
  end

end
