module Pebbles
  class Uid
    class Genus < Labels

      def ambiguous?
        value == '*' || values.empty? || wildcard?
      end

      def species
        return if size <= 1

        tail.join('.')
      end

      def species?
        species != '*'
      end

      def to_hash(options = {})
        super({:verbose => false, :name => 'genus'}.merge(options))
      end

    end
  end
end
