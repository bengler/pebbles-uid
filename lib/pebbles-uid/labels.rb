module Pebbles
  class Uid
    class Labels

      attr_reader :values, :prefix
      def initialize(*values)
        @values = values.flatten.compact.map {|v| v.split('.') }.flatten
      end

      def first
        values.first
      end

      def tail
        values[1..-1]
      end

      def ambiguous?
        value == '*' || values.empty? || wildcard?
      end

      def valid_with?(pattern)
        !empty? && values.all? {|value| value[pattern] }
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

      def wildcard?
        !!(value =~ /[\*\|\^]/)
      end

      def to_hash(options = {})
        Conditions.new(values, options).to_hash
      end

    end
  end
end
