# A key => value representation of sets of labels
# used for elastic search or active record as indexing
# or search conditions.
module Pebbles
  class Uid
    class Conditions

      NO_MARKER = Class.new

      attr_reader :values, :name, :suffix, :stop, :verbose

      def initialize(values, options = {})
        @values = values
        @name = options.fetch(:name) { 'label' }
        @suffix = options.fetch(:suffix) { nil }
        @verbose = options.fetch(:verbose) { true }
        @stop = options.fetch(:stop) { NO_MARKER }
      end

      alias :verbose? :verbose

      def next
        label(values.length)
      end

      def to_hash
        return {name => values.join('.')} unless verbose?

        collection = {}
        values.each_with_index do |value, i|
          collection[label(i)] = value
        end
        if use_stop_marker?
          collection[label(values.length)] = stop
        end
        collection
      end

      def label(i)
        [name, i, suffix].compact.join('_')
      end

      def use_stop_marker?
        stop != NO_MARKER
      end

    end
  end
end
