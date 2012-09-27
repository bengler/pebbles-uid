require 'pebbles-uid/labels'
require 'pebbles-uid/oid'

describe Pebbles::Uid::Oid do

  describe "wildcard" do
    subject { Pebbles::Uid::Oid.new('*') }

    its(:wildcard?) { should be_true }
  end

end
