require "pebbles-uid/version"

require "pebbles-uid/conditions"
require "pebbles-uid/labels"
require "pebbles-uid/species"
require "pebbles-uid/path"
require "pebbles-uid/oid"

module Pebbles
  class Uid

    def initialize(s)
      /^(?<species>.*):(?<path>[^\$]*)\$(?<oid>.*)$/ =~ s
      @species = Species.new(species)
      @path = Path.new(path)
      @oid = Oid.new(oid)
    end

    def valid?
      [@species, @path, @oid].all? {|e| e.valid?}
    end

    def to_s
      "#{@species}:#{@path}$#{@oid}"
    end

    def parsed
      [@species.to_s, @path.to_s, @oid.to_s]
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
      @oid.to_s
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

  end
end
