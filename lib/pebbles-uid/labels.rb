module Pebbles
  class Uid
    class Labels

      NO_MARKER = Class.new

      attr_reader :values, :name, :suffix, :stop, :max_depth
      def initialize(*values)
        options = values.pop if values.last.is_a?(Hash)
        options ||= {}
        @values = values.flatten.compact.map {|v| v.split('.') }.flatten
        @name = options[:name]
        @suffix = options[:suffix]
        @stop = options.fetch(:stop) { NO_MARKER }
        @max_depth = options[:max_depth]
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

      def to_hash
        conditions.to_hash
      end

      def next_label
        conditions.next
      end

      def conditions
        unless @conditions
          options = {:name => name, :suffix => suffix}
          options.merge!(:stop => stop) if use_stop_marker?
          @conditions = Conditions.new(values, options)
        end
        @conditions
      end

      def use_stop_marker?
        stop != NO_MARKER && !(values.size == max_depth)
      end

    end
  end
end
