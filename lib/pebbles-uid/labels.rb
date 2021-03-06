module Pebbles
  class Uid
    class Labels
      include Enumerable

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

      def each(&block)
        values.each {|value| yield value}
      end

      def tail
        values[1..-1]
      end

      def parent_of?(other)
        return false if values == other.values
        parent = true
        values.each_with_index do |value, i|
          parent = false unless value == other.values[i]
        end
        parent
      end

      def child_of?(other)
        child = true
        other.values.each_with_index do |label, i|
          if label != values[i]
            child = false
          end
        end
        child && other.size != size
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
