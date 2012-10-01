require 'pebbles-uid/labels'
require 'pebbles-uid/conditions'
require 'pebbles-uid/genus'

describe Pebbles::Uid::Genus do

  subject { Pebbles::Uid::Genus.new('unicorn') }

  its(:to_s) { should eq('unicorn') }

  its(:species) { should be_nil }
  its(:to_hash) { should eq('genus' => 'unicorn') }

  context "subtypes" do

    subject { Pebbles::Uid::Genus.new('unicorn', 'dust', 'sparkles') }
    its(:to_s) { should eq('unicorn.dust.sparkles') }
    its(:species) { should eq('dust.sparkles') }
    its(:to_hash) { should eq('genus' => 'unicorn.dust.sparkles') }

    it "doesn't have a species if there's a wildcard" do
      genus = Pebbles::Uid::Genus.new('unicorn.*')
      genus.species?.should == false
    end

    it "can customize the hash" do
      subject.to_hash(:verbose => true).should eq('genus_0' => 'unicorn', 'genus_1' => 'dust', 'genus_2' => 'sparkles')
    end
  end

  it { Pebbles::Uid::Genus.new('unicorn.horn').species.should eq('horn') }

end
