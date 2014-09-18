require 'pebbles-uid/wildcard'

describe Pebbles::Uid::Wildcard do

  # This might not actually be necessary/relevant
  specify "non-wildcard paths are valid" do
    Pebbles::Uid::Wildcard.valid?('a.b.d').should == true
  end

  describe '#valid?' do
    it 'returns false for nil' do
      expect(Pebbles::Uid::Wildcard.valid?(nil)).to be_false
    end

    it 'returns true for empty string' do
      expect(Pebbles::Uid::Wildcard.valid?('')).to be_true
    end
  end

  context "terminating asterisk representing entire label" do
    [
      '*', 'a.b.c.*', 'a.b|c.*', 'a.^b.c.*'
    ].each do |path|
      specify "#{path} is valid" do
        Pebbles::Uid::Wildcard.valid?(path).should == true
      end
    end

    ['*a', 'a*', '*.b', 'a.*.b'].each do |path|
      specify "#{path} is invalid" do
        Pebbles::Uid::Wildcard.valid?(path).should == false
      end
    end
  end

  context "pipes separate labels" do
    ['a|b', 'a.b|c.d', 'a|b.c|d'].each do |path|
      specify "#{path} is valid" do
        Pebbles::Uid::Wildcard.valid?(path).should == true
      end
    end

    ['|', 'a.|b', 'a.b|', 'a.|b.c', 'a.b|.c'].each do |path|
      specify "#{path} is invalid" do
        Pebbles::Uid::Wildcard.valid?(path).should == false
      end
    end
  end

  context "carets start an ancestry chain" do
    ['^a', '^a.b', 'a.^b.c.*'].each do |path|
      specify "#{path} is valid" do
        Pebbles::Uid::Wildcard.valid?(path).should == true
      end
    end

    ['^', '^.a', 'a^', 'a^b.c', '^a.^b'].each do |path|
      specify "#{path} is invalid" do
        Pebbles::Uid::Wildcard.valid?(path).should == false
      end
    end
  end
end
