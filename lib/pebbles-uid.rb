require "pebbles-uid/version"

require "pebbles-uid/conditions"
require "pebbles-uid/labels"
require "pebbles-uid/species"
require "pebbles-uid/path"
require "pebbles-uid/oid"

module Pebbles
  class Uid

    class WildcardUidError < RuntimeError; end

    class << self

      def parse(s)
        /^(?<species>.*):(?<path>[^\$]*)\$?(?<oid>.*)$/ =~ s
        [species, path, oid]
      end

      def species(s)
        parse(s)[0]
      end

      def path(s)
        parse(s)[1]
      end

      def oid(s)
        parse(s)[2]
      end

    end

    def initialize(s)
      species, path, oid = self.class.parse(s)
      @species = Species.new(species)
      @path = Path.new(path)
      @oid = Oid.new(oid)
      raise WildcardUidError.new if wildcard?
    end

    def valid?
      valid_species? && valid_path? && valid_oid?
    end

    def valid_species?
      @species.values.select {|value| value[/[^a-z0-9\._-]/]}.empty?
    end

    def valid_path?
      !@path.values.empty? && @path.values.none? {|value| value[/[^a-z0-9\._-]/] }
    end

    def valid_oid?
      true
    end

    def to_s
      s = @species.to_s
      s << ":#{@path}"
      s << "$#{@oid}" unless @oid.empty?
      s
    end

    def parsed
      [species, path, oid].compact
    end

    def realm
      @path.realm
    end

    def species
      @species.to_s
    end

    def genus
      @species.genus
    end

    def path
      @path.to_s
    end

    def oid
      @oid.empty? ? nil : @oid.to_s
    end

    def cache_key
      "#{species}:#{realm}$#{oid}"
    end

    def to_hash(options = {})
      result = hashify(:species, options)
      result.merge! hashify(:path, options)
      result.merge! hashify(:oid, options)
    end

    private

    def wildcard?
      @species.wildcard? || @path.wildcard? || @oid.wildcard?
    end

    def hashify(key, options)
      label = options.delete(key)
      options = options.merge(:name => label) if label
      instance_variable_get(:"@#{key}").to_hash(options)
    end

  end
end
