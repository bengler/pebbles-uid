module Pebbles
  class Uid

    class Oid < Labels

      def ambiguous?
        value == '*' || value.empty?
      end

      def empty?
        value.empty?
      end

      def multiple?
        !!(value =~ /[\|]/)
      end

      def wildcard?
        value == '*' || multiple?
      end

      def to_hash(options = {})
        options.delete(:verbose)
        super({:verbose => false, :name => 'oid'}.merge(options))
      end

    end
  end
end
