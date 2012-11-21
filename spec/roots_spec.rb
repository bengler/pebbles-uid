require 'pebbles-uid'

describe Pebbles::Uid::Roots do

  specify "empty list is empty :)" do
    Pebbles::Uid::Roots.new([]).unique.should eq([])
  end

  specify "with one, has a single root" do
    Pebbles::Uid::Roots.new(['boy:a$1']).unique.should eq(['boy:a$1'])
  end

  specify "does not keep duplicates" do
    Pebbles::Uid::Roots.new(['girl:a$1', 'girl:a$1']).unique.should eq(['girl:a$1'])
  end

  specify "with two, returns just the parent" do
    Pebbles::Uid::Roots.new(['kid:a$1', 'kid:a.b$2']).unique.should eq(['kid:a$1'])
  end

  specify "with two, returns just the parent, regardless of sort order" do
    Pebbles::Uid::Roots.new(['baby:a.b$1', 'baby:a$2']).unique.should eq(['baby:a$2'])
  end

  specify "with non-intersecting nodes, returns both" do
    Pebbles::Uid::Roots.new(['goat:a.b$1', 'goat:a.c$2']).unique.should eq(['goat:a.b$1', 'goat:a.c$2'])
  end

  specify "with similar, but non-intersecting nodes, returns both" do
    Pebbles::Uid::Roots.new(['pig:a.b.c$1', 'pig:a.c.d$2']).unique.should eq(['pig:a.b.c$1', 'pig:a.c.d$2'])
  end

end
