module Pebbles
  class Uid

    class << self

      def parse(s)
        /^(?<genus>.*):(?<path>[^\$]*)\$?(?<oid>.*)$/ =~ s
        [genus, path, oid.empty? ? nil : oid]
      end

    end
  end
end

