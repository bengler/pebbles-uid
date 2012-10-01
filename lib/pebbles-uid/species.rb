module Pebbles
  class Uid
    class Species < Labels

      def ambiguous?
        value == '*' || values.empty? || wildcard?
      end

      def genus
        return if size <= 1

        tail.join('.')
      end

      def genus?
        genus != '*'
      end

      def to_hash(options = {})
        super({:verbose => false, :name => 'species'}.merge(options))
      end

    end
  end
end
