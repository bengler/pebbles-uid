module Pebbles
  class Uid

    class << self
      def cache_key(uid)
        genus, path, oid = parse(uid)
        "#{genus}:#{Labels.new(path).first}.*$#{oid}"
      end
    end

  end
end

