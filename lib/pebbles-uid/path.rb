module Pebbles
  class Uid
    class Path < Labels

      def realm
        values.first
      end

      def to_hash(options = {})
        super({:name => 'label'}.merge(options))
      end

      def valid?
        !values.empty? && values.none? {|label| label[/[^a-z0-9\._-]/] }
      end

    end
  end
end
