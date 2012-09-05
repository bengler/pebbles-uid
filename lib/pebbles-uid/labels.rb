module Pebbles
  class Uid
    class Labels

      attr_reader :values, :prefix
      def initialize(*values)
        @values = values.map {|v| v.split('.') }.flatten
      end

      def to_a
        values
      end

      def to_s
        values.join('.')
      end

      def to_hash(options = {})
        Conditions.new(values, options).to_hash
      end

    end
  end
end
