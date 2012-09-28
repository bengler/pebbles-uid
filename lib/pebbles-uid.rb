require "pebbles-uid/version"

require 'pebbles-uid/query'
require 'pebbles-uid/cached_query'
require "pebbles-uid/conditions"
require "pebbles-uid/labels"
require "pebbles-uid/species"
require "pebbles-uid/path"
require "pebbles-uid/oid"

module Pebbles
  class Uid

    class << self

      def query(s)
        Pebbles::Uid::Query.new(s)
      end

      def parse(s)
        /^(?<species>.*):(?<path>[^\$]*)\$?(?<oid>.*)$/ =~ s
        [species, path, oid.empty? ? nil : oid]
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

      def valid_path?(path)
        return false if path.empty?
        Path.new(path).valid_with?(/^[a-z0-9_-]+$/)
      end
    end

    attr_reader :species, :path, :oid
    def initialize(s)
      @species, @path, @oid = self.class.parse(s)
      if species.empty?
        raise ArgumentError.new("Invalid Uid: #{s}. Species is required.")
      end
      if path.empty?
        raise ArgumentError.new("Invalid Uid: #{s}. Realm is required.")
      end
    end

    def realm
      @realm ||= path.split('.').first
    end

    def genus
      @genus ||= species_labels.genus
    end

    def path_labels
      @path_labels ||= Path.new(path)
    end

    def species_labels
      @species_labels ||= Species.new(species)
    end

    def valid?
      valid_species? && valid_path? && valid_oid?
    end

    def valid_species?
      species_labels.valid_with?(/^[a-z0-9_-]+$/)
    end

    def valid_path?
      self.class.valid_path?(path)
    end

    def valid_oid?
      return true unless oid?
      oid.split('|').size == 1
    end

    def oid?
      !!oid
    end

    def to_s
      s = "#{species}:#{path}"
      s << "$#{oid}" if oid
      s
    end

    def parsed
      [species, path, oid].compact
    end

    def cache_key
      "#{species}:#{realm}$#{oid}"
    end
  end
end
