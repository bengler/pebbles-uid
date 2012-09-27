require "pebbles-uid/version"

require "pebbles-uid/conditions"
require "pebbles-uid/labels"
require "pebbles-uid/species"
require "pebbles-uid/path"
require "pebbles-uid/oid"

module Pebbles
  class Uid

    class WildcardUidError < RuntimeError; end

    def initialize(s)
      /^(?<species>.*):(?<path>[^\$]*)\$?(?<oid>.*)$/ =~ s
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
      result = {}
      label = options.delete(:species)
      options = options.merge(:name => label) if label
      result = result.merge @species.to_hash(options)

      label = options.delete(:path)
      options = options.merge(:name => label) if label
      result = result.merge @path.to_hash(options)

      label = options.delete(:oid)
      options = options.merge(:name => label) if label
      result = result.merge @oid.to_hash(options)
    end

    private

    def wildcard?
      @species.wildcard? || @path.wildcard? || @oid.wildcard?
    end

  end
end
