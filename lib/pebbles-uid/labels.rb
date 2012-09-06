module Pebbles
  class Uid
    class Labels

      attr_reader :values, :prefix
      def initialize(*values)
        @values = values.flatten.map {|v| v.split('.') }.flatten
      end

      def tail
        values[1..-1]
      end

      def size
        values.size
      end

      def to_a
        values
      end

      def to_s
        values.join('.')
      end
      alias :value :to_s

      def empty?
        values.empty?
      end

      def to_hash(options = {})
        Conditions.new(values, options).to_hash
      end

    end
  end
end
