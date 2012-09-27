module Pebbles
  class Uid

    class << self
      def parse(s)
        /^(?<species>.*):(?<path>[^\$]*)\$?(?<oid>.*)$/ =~ s
        [species, path, oid]
      end
    end

  end
end
