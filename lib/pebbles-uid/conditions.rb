# A key => value representation of sets of labels
# used for elastic search or active record as indexing
# or search conditions.
module Pebbles
  class Uid
    class Conditions

      NO_MARKER = Class.new

      attr_reader :values, :name, :suffix, :stop

      def initialize(values, options = {})
        @values = values
        @name = options.fetch(:name) { 'label' }
        @suffix = options.fetch(:suffix) { nil }
        @stop = options.fetch(:stop) { NO_MARKER }
        if values.last == '*'
          @stop = NO_MARKER
          @values.pop
        end
      end

      def next
        label(values.length)
      end

      def to_hash
        collection = labelize
        collection.merge!(stop_label) if use_stop_marker?
        collection
      end

      def labelize

        optional_part = false
        labels = values.map do |label|
          if label =~ /^\^/
            label.gsub!(/^\^/, '')
            optional_part = true
          end

          result = label.include?('|') ? label.split('|') : label
          result = [result, nil].flatten if optional_part
          result
        end

        collection = {}
        labels.each_with_index do |value, i|
          collection[label(i)] = value
        end
        collection
      end

      def label(i = nil)
        [name, i, suffix].compact.join('_')
      end

      def stop_label
        { label(values.length) => stop }
      end

      def use_stop_marker?
        stop != NO_MARKER
      end

    end
  end
end
