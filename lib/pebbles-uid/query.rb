module Pebbles
  class Uid
    class Query
      class InvalidCacheQuery < RuntimeError; end

      attr_reader :species, :path, :oid
      def initialize(s)
        @query = s
        @species, @path, @oid = Pebbles::Uid.parse(s)
        @species_labels = Species.new(species)
        @path_labels = Path.new(path)
        @oid_box = Oid.new(oid)
      end

      def to_s
        @query
      end

      def species?
        !(species_labels.empty? || species_labels.value == '*')
      end

      def path?
        !(path_labels.empty? || path_labels.value == '*')
      end

      def oid?
        !(oid_box.empty? || oid_box.value == '*')
      end

      def specific?
        false
      end

      def try_cache?
        return false unless species? && path_labels.realm? && oid?
        true
      end

      def cache_keys
        raise InvalidCacheQuery unless try_cache?

        oid.split('|').map do |id|
          "#{species}:#{path_labels.realm}$#{id}"
        end
      end


      private

      attr_reader :species_labels, :path_labels, :oid_box
    end
  end
end
