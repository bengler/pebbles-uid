module Pebbles
  class Uid
    class Query

      NO_MARKER = Class.new

      attr_reader :term, :terms, :species, :path, :oid,
        :species_name, :path_name, :suffix, :stop
      def initialize(term, options = {})
        @term = term
        @species_name = options.fetch(:species) { 'species' }
        @path_name = options.fetch(:path) { 'path' }
        @suffix = options[:suffix]
        @stop = options.fetch(:stop) { NO_MARKER }

        if wildcard_query?
          @terms = [term]
        else
          @terms = extract_terms
        end

        if list?
          @species, @path, _ = Pebbles::Uid.parse(terms.first)
        else
          @species, @path, @oid = Pebbles::Uid.parse(term)
        end
      end

      def for_one?
        !wildcard_query? && !list?
      end

      def list?
        terms.size != 1 or term.strip[-1..-1] == ","
      end

      def list
        if !list?
          raise "Cannot expand non-list query"
        end
        terms
      end

      def collection?
        wildcard_query?
      end

      def path?
        @path && @path.split('.').reject {|s| s == '*'}.length > 0
      end

      def species?
        @species && @species != '*'
      end

      def epiteth?
        !species_wrapper.tail.empty?
      end

      def genus
        species.split('.').first
      end

      def epiteth
        species_wrapper.tail.join('.')
      end

      def oid?
        !!@oid && @oid != '*'
      end

      def cache_keys
        terms.map { |t| Pebbles::Uid.cache_key(t) }
      end

      def to_hash
        if list?
          raise RuntimeError.new('Cannot compute a conditions hash for a list of uids')
        end

        hash = species_wrapper.to_hash.merge(path_wrapper.to_hash)
        if oid?
          oid_key = ['oid', suffix].compact.join('_').to_sym
          hash = hash.merge(oid_key => oid)
        end
        hash
      end

      def next_path_label
        path_wrapper.next_label
      end

      private

      def species_wrapper
        unless @species_wrapper
          options = {:name => species_name, :suffix => suffix}
          options.merge!(:stop => stop) if use_stop_marker?
          @species_wrapper = Labels.new(species, options)
        end
        @species_wrapper
      end

      def path_wrapper
        unless @path_wrapper
          options = {:name => path_name, :suffix => suffix}
          options.merge!(:stop => stop) if use_stop_marker?
          @path_wrapper = Labels.new(path, options)
        end
        @path_wrapper
      end

      def wildcard_query?
        return false if term.include?(',')
        species, _, oid = Pebbles::Uid.parse(term)
        return true if Labels.new(species).wildcard?
        return true if oid.nil? || oid.empty? || oid == '*'
        false
      end

      def extract_terms
        term.split(',').map do |uid|
          _species, _path, _oid = Pebbles::Uid.parse(uid)
          species_labels = Labels.new(_species)
          path_labels = Labels.new(_path)
          oid_box = Oid.new(_oid)

          raise ArgumentError.new('Realm must be specified') if path_labels.empty? || path_labels.first == '*'
          raise ArgumentError.new('Species must unambiguous') if species_labels.ambiguous?
          raise ArgumentError.new('Oid must be unambiguous') if oid_box.ambiguous?

          @realm ||= path_labels.first
          raise ArgumentError.new('One realm at a time, please') if @realm != path_labels.first

          if oid_box.multiple?
            _oid.split('|').map do |s|
              "#{_species}:#{_path}$#{s}"
            end
          else
            uid
          end
        end.flatten
      end

      def use_stop_marker?
        stop != NO_MARKER
      end
    end
  end
end
