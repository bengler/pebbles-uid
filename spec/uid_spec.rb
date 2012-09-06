require 'pebbles-uid'

describe Pebbles::Uid do

  let(:uid) { 'post.card:tourism.norway.fjords$1234' }

  subject { Pebbles::Uid.new(uid) }
  its(:to_s) { should eq(uid) }
  its(:parsed) { should eq(['post.card', 'tourism.norway.fjords', '1234']) }

  its(:realm) { should eq('tourism') }
  its(:species) { should eq('post.card') }
  its(:genus) { should eq('card') }
  its(:path) { should eq('tourism.norway.fjords') }
  its(:oid) { should eq('1234') }

  its(:valid?) { should be_true }

  specify ":to_hash creates reasonable query params (e.g. for active record)" do
    expected = {
      'species' => 'post.card',
      'path_0' => 'tourism',
      'path_1' => 'norway',
      'path_2' => 'fjords',
      'oid' => '1234'
    }
    subject.to_hash.should eq(expected)
  end

  specify ":to_hash has overrides to make indexable params (e.g. for elastic search)" do
    expected = {
      'species_0_' => 'post',
      'species_1_' => 'card',
      'path_0_' => 'tourism',
      'path_1_' => 'norway',
      'path_2_' => 'fjords',
      'oid_' => '1234'
    }
    subject.to_hash(:verbose => true, :suffix => '').should eq(expected)
  end

  specify ":to_hash overrides can get totally ridiculous" do
     expected = {
      'klass_0_xyz' => 'post',
      'klass_1_xyz' => 'card',
      'label_0_xyz' => 'tourism',
      'label_1_xyz' => 'norway',
      'label_2_xyz' => 'fjords',
      'id_xyz' => '1234'
    }
    subject.to_hash(:verbose => true, :suffix => 'xyz', :species => 'klass', :path => 'label', :oid => 'id').should eq(expected)
  end

end
