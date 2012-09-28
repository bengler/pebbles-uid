module Pebbles
  class Uid
    class Query

      attr_reader :species, :path, :oid
      def initialize(s)
        species, path, oid = Pebbles::Uid.parse(s)
        @species = species
        @path = path
        @oid = oid
      end

      def to_s
        s = "#{species}:#{path}"
        s << "$#{oid}" if oid
        s
      end
    end
  end
end
