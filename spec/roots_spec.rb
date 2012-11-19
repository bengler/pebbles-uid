require 'pebbles-uid'

describe Pebbles::Uid do

  specify "single node" do
    Pebbles::Uid.root_paths(['person:a$1']).should eq(['a'])
  end

  specify "occluded node" do
    Pebbles::Uid.root_paths(['person:a$1', 'person:a.b$2']).should eq(['a'])
  end

  specify "non-intersecting nodes" do
    Pebbles::Uid.root_paths(['person:a.b$1', 'person:a.c$2']).should eq(['a.b', 'a.c'])
  end

  specify "weird non-intersecting nodes" do
    Pebbles::Uid.root_paths(['person:a.b.c$1', 'person:a.c.d$2']).should eq(['a.b.c', 'a.c.d'])
  end

end
