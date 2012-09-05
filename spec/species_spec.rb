require 'pebbles-uid/labels'
require 'pebbles-uid/conditions'
require 'pebbles-uid/species'

describe Pebbles::Uid::Species do

  subject { Pebbles::Uid::Species.new('unicorn') }

  its(:to_s) { should eq('unicorn') }

  its(:genus) { should be_nil }
  its(:valid?) { should be_true }
  its(:to_hash) { should eq('species' => 'unicorn') }

  context "subspecies" do

    subject { Pebbles::Uid::Species.new('unicorn', 'dust', 'sparkles') }
    its(:to_s) { should eq('unicorn.dust.sparkles') }
    its(:genus) { should eq('dust.sparkles') }
    its(:to_hash) { should eq('species' => 'unicorn.dust.sparkles') }
    its(:valid?) { should be_true }

    it "can customize the hash" do
      subject.to_hash(:verbose => true).should eq('species_0' => 'unicorn', 'species_1' => 'dust', 'species_2' => 'sparkles')
    end

  end

  it { Pebbles::Uid::Species.new('unicorn.horn').genus.should eq('horn') }

  %w(- . _ 8).each do |char|
    it "accepts #{char}" do
      Pebbles::Uid::Species.new("uni#{char}corn").should be_valid
    end
  end

  %w(* ! % { ? $).each do |char|
    it "rejects #{char}" do
      Pebbles::Uid::Species.new("uni#{char}corn").should_not be_valid
    end
  end

end
