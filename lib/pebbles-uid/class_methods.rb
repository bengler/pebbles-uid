module Pebbles
  class Uid
    class << self

      def roots(uids)
        Pebbles::Uid::Roots.new(uids).unique
      end

      def parse(s)
        /^(?<species>[^:]*):(?<path>[^\$]*)\$?(?<oid>.*)$/ =~ s
        [species, path, oid && oid.empty? ? nil : oid]
      end

      def build(species, path, oid)
        s = "#{species}:#{path}"
        s << "$#{oid}" if oid
        s
      end

      def query(s, options = {})
        Pebbles::Uid::Query.new(s, options)
      end

      def cache_key(uid)
        species, path, oid = parse(uid)
        "#{species}:#{Labels.new(path).first}.*$#{oid}"
      end

      def species(s)
        parse(s)[0]
      end

      def genus(s)
        parse(s)[0].split('.').first
      end

      def epiteth(s)
        parse(s)[0].split('.')[1..-1].join('.')
      end

      def path(s)
        parse(s)[1]
      end

      def oid(s)
        parse(s)[2]
      end

      def valid_path?(path)
        return false if path.empty?
        Labels.new(path).valid_with?(/^[a-z0-9_-]+$/)
      end

      def valid_species?(species)
        return false if species.empty?
        Labels.new(species).valid_with?(/^[a-z0-9_-]+$/)
      end

      def valid_oid?(oid)
        return true if !oid || oid.empty?
        !!(oid =~ /^[^,|]+$/)
      end
    end
  end
end

