module Pebbles
  class Uid
    class Oid < Labels

      def valid?
        true
      end

      def to_hash(options = {})
        options.delete(:verbose)
        super({:verbose => false, :name => 'oid'}.merge(options))
      end

    end
  end
end
