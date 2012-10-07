module Pebbles
  class Uid

    class << self
      def cache_key(uid)
        genus, path, oid = parse(uid)
        "#{genus}:#{Path.new(path).realm}.*$#{oid}"
      end
    end

  end
end

