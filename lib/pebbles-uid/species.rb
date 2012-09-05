module Pebbles
  class Uid
    class Species

      attr_reader :labels
      def initialize(*labels)
        @labels = Labels.new(labels)
      end

      def genus
        return if labels.size == 1

        labels.tail.join('.')
      end

      def valid?
        labels.select {|label| label[/[^a-z0-9\._-]/]}.empty?
      end

      def to_hash(options = {})
        labels.to_hash({:verbose => false, :name => 'species'}.merge(options))
      end

      def to_s
        labels.to_s
      end

    end
  end
end
