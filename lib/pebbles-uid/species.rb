module Pebbles
  class Uid
    class Species < Labels

      def genus
        return if size == 1

        tail.join('.')
      end

      def valid?
        values.select {|value| value[/[^a-z0-9\._-]/]}.empty?
      end

      def to_hash(options = {})
        super({:verbose => false, :name => 'species'}.merge(options))
      end

    end
  end
end
