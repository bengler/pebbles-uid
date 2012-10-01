require 'pebbles-uid/labels'
require 'pebbles-uid/conditions'
require 'pebbles-uid/species'

describe Pebbles::Uid::Species do

  subject { Pebbles::Uid::Species.new('unicorn') }

  its(:to_s) { should eq('unicorn') }

  its(:genus) { should be_nil }
  its(:to_hash) { should eq('species' => 'unicorn') }

  context "subspecies" do

    subject { Pebbles::Uid::Species.new('unicorn', 'dust', 'sparkles') }
    its(:to_s) { should eq('unicorn.dust.sparkles') }
    its(:genus) { should eq('dust.sparkles') }
    its(:to_hash) { should eq('species' => 'unicorn.dust.sparkles') }

    it "doesn't have a genus if there's a wildcard" do
      species = Pebbles::Uid::Species.new('unicorn.*')
      species.genus?.should == false
    end

    it "can customize the hash" do
      subject.to_hash(:verbose => true).should eq('species_0' => 'unicorn', 'species_1' => 'dust', 'species_2' => 'sparkles')
    end
  end

  it { Pebbles::Uid::Species.new('unicorn.horn').genus.should eq('horn') }

end
