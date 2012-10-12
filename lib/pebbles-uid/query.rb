module Pebbles
  class Uid
    class Query

      attr_reader :term, :terms, :genus, :path, :oid
      def initialize(term)
        @term = term

        if wildcard_query?
          @terms = [term]
          @genus, @path, @oid = Pebbles::Uid.parse(term)
        else
          @terms = extract_terms
        end
      end

      def for_one?
        !wildcard_query? && terms.size == 1
      end

      def list?
        terms.size != 1
      end

      def collection?
        wildcard_query?
      end

      def path?
        @path && @path.split('.').reject {|s| s == '*'}.length > 0
      end

      def genus?
        @genus && @genus != '*'
      end

      def species?
        !genus_wrapper.tail.empty?
      end

      def species
        genus_wrapper.tail.join('.')
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

        hash = genus_wrapper.to_hash.merge(path_wrapper.to_hash)
        hash = hash.merge(:oid => oid) if oid?
        hash
      end

      private

      def genus_wrapper
        @genus_wrapper ||= Labels.new(genus, :name => 'genus')
      end

      def path_wrapper
        @path_wrapper ||= Labels.new(path, :name => 'path')
      end

      def wildcard_query?
        return false if term.include?(',')
        genus, _, oid = Pebbles::Uid.parse(term)
        return true if Labels.new(genus).wildcard?
        return true if oid.nil? || oid.empty? || oid == '*'
        false
      end

      def extract_terms
        term.split(',').map do |uid|
          _genus, _path, _oid = Pebbles::Uid.parse(uid)
          genus_labels = Labels.new(_genus)
          path_labels = Labels.new(_path)
          oid_box = Oid.new(_oid)

          raise ArgumentError.new('Realm must be specified') if path_labels.empty? || path_labels.first == '*'
          raise ArgumentError.new('Genus must unambiguous') if genus_labels.ambiguous?
          raise ArgumentError.new('Oid must be unambiguous') if oid_box.ambiguous?

          @realm ||= path_labels.first
          raise ArgumentError.new('One realm at a time, please') if @realm != path_labels.first

          if oid_box.multiple?
            _oid.split('|').map do |s|
              "#{_genus}:#{_path}$#{s}"
            end
          else
            uid
          end
        end.flatten
      end

    end
  end
end
