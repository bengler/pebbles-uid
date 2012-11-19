require "pebbles-uid/version"

require 'pebbles-uid/wildcard'
require 'pebbles-uid/class_methods'
require 'pebbles-uid/query'
require "pebbles-uid/conditions"
require "pebbles-uid/labels"
require "pebbles-uid/oid"
require "pebbles-uid/roots"

module Pebbles
  class Uid

    attr_reader :species, :path, :oid
    def initialize(s)
      @species, @path, @oid = self.class.parse(s)
      unless valid_species?
        raise ArgumentError.new("Invalid Uid: #{s}. Species is invalid.")
      end
      unless valid_path?
        raise ArgumentError.new("Invalid Uid: #{s}. Path is invalid.")
      end

      if oid == '*'
        raise ArgumentError.new("Invalid Uid: #{s}. Cannot have wildcard oid.")
      end

      if species.empty?
        raise ArgumentError.new("Invalid Uid: #{s}. Species is required.")
      end
      if path.empty?
        raise ArgumentError.new("Invalid Uid: #{s}. Realm is required.")
      end

    end

    def epiteth
      @epiteth ||= species.split('.')[1..-1].join('.')
    end

    def genus
      @genus ||= species.split('.').first
    end

    def realm
      @realm ||= path.split('.').first
    end

    def species
      @species ||= species_labels.tail.join('.')
    end

    def path_labels
      @path_labels ||= Labels.new(path, :name => 'path')
    end

    def species_labels
      @species_labels ||= Labels.new(species, :name => 'species')
    end

    def valid?
      valid_species? && valid_path? && valid_oid?
    end

    def valid_species?
      self.class.valid_species?(species)
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
      Pebbles::Uid.build species, path, oid
    end

    def parsed
      [species, path, oid].compact
    end

    def to_hash
      hash = species_labels.to_hash.merge(path_labels.to_hash)
      hash = hash.merge(:oid => oid) if oid?
      hash
    end

    def cache_key
      "#{species}:#{realm}.*$#{oid}"
    end

  end
end
