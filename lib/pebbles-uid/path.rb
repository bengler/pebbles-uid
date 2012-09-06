module Pebbles
  class Uid
    class Path

      attr_reader :labels
      def initialize(*labels)
        @labels = Labels.new(labels)
      end

      def realm
        labels.first
      end

      def to_s
        labels.to_s
      end

      def to_a
        labels.to_a
      end

      def to_hash(options = {})
        labels.to_hash({:name => 'label'}.merge(options))
      end

      def valid?
        !labels.empty? && labels.none? {|label| label[/[^a-z0-9\._-]/] }
      end

    end
  end
end
