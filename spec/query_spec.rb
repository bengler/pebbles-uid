require 'pebbles-uid'

describe Pebbles::Uid::Query do

  context "for a single resource" do
    it "is not a list"
    it "is not a collection"

    it "handles a full uid"
    it "handles a wildcard path if realm is given"

    it "bails without realm"
    it "bails with unspecific species"
    it "bails with unspecified oid"
  end

  context "for a list of resources" do
    it "is not for a single resource"
    it "is not a collection"

    it "handles a comma separated list of single-resource uids"
    it "handles a pipe-delimited list of oids"

    it "bails without realm"
    it "bails with unspecific species"
    it "bails with unspecified oid"
  end

  context "for a collection of resources" do
    it "is not for a single resource"
    it "is not a list"

    it "does all sorts of crazy-complicated wildcard stuff"
  end

end
