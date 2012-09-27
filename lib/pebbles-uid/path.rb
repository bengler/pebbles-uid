module Pebbles
  class Uid
    class Path < Labels

      def realm
        values.first
      end

      def to_hash(options = {})
        super({:name => 'path'}.merge(options))
      end

    end
  end
end
