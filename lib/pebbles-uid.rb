require "pebbles-uid/version"

require 'pebbles-uid/parse'
require 'pebbles-uid/cache_key'
require 'pebbles-uid/query'
require "pebbles-uid/conditions"
require "pebbles-uid/labels"
require "pebbles-uid/genus"
require "pebbles-uid/path"
require "pebbles-uid/oid"

module Pebbles
  class Uid

    class << self

      def parse(s)
        /^(?<genus>.*):(?<path>[^\$]*)\$?(?<oid>.*)$/ =~ s
        [genus, path, oid.empty? ? nil : oid]
      end

      def query(s)
        Pebbles::Uid::Query.new(s)
      end

      def genus(s)
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

      def valid_genus?(genus)
        return false if genus.empty?
        Genus.new(genus).valid_with?(/^[a-z0-9_-]+$/)
      end

      def valid_oid?(oid)
        return true if !oid || oid.empty?
        !!(oid =~ /^[^,|]+$/)
      end
    end

    attr_reader :genus, :path, :oid
    def initialize(s)
      @genus, @path, @oid = self.class.parse(s)
      unless valid_genus?
        raise ArgumentError.new("Invalid Uid: #{s}. Genus is invalid.")
      end
      unless valid_path?
        raise ArgumentError.new("Invalid Uid: #{s}. Path is invalid.")
      end

      if oid == '*'
        raise ArgumentError.new("Invalid Uid: #{s}. Cannot have wildcard oid.")
      end

      if genus.empty?
        raise ArgumentError.new("Invalid Uid: #{s}. Genus is required.")
      end
      if path.empty?
        raise ArgumentError.new("Invalid Uid: #{s}. Realm is required.")
      end
    end

    def realm
      @realm ||= path.split('.').first
    end

    def species
      @species ||= genus_labels.species
    end

    def path_labels
      @path_labels ||= Path.new(path)
    end

    def genus_labels
      @genus_labels ||= Genus.new(genus)
    end

    def valid?
      valid_genus? && valid_path? && valid_oid?
    end

    def valid_genus?
      self.class.valid_genus?(genus)
    end

    def valid_path?
      self.class.valid_path?(path)
    end

    def valid_oid?
      self.class.valid_oid?(oid)
    end

    def oid?
      !!oid
    end

    def to_s
      s = "#{genus}:#{path}"
      s << "$#{oid}" if oid
      s
    end

    def parsed
      [genus, path, oid].compact
    end

    def cache_key
      "#{genus}:#{realm}.*$#{oid}"
    end
  end
end
