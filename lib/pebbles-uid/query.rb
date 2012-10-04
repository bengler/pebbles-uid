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
        !!genus_wrapper.species
      end

      def species
        genus_wrapper.species
      end

      def oid?
        !!@oid && @oid != '*'
      end

      def cache_keys
        terms.map { |t| Pebbles::Uid.cache_key(t) }
      end

      private

      def genus_wrapper
        @genus_wrapper ||= Genus.new(genus)
      end

      def wildcard_query?
        return false if term.include?(',')
        genus, _, oid = Pebbles::Uid.parse(term)
        return true if Genus.new(genus).wildcard?
        return true if oid.nil? || oid.empty? || oid == '*'
        false
      end

      def extract_terms
        term.split(',').map do |uid|
          _genus, _path, _oid = Pebbles::Uid.parse(uid)
          genus_labels = Genus.new(_genus)
          path_labels = Path.new(_path)
          oid_box = Oid.new(_oid)

          raise ArgumentError.new('Realm must be specified') unless path_labels.realm?
          raise ArgumentError.new('Genus must unambiguous') if genus_labels.ambiguous?
          raise ArgumentError.new('Oid must be unambiguous') if oid_box.ambiguous?

          @realm ||= path_labels.realm
          raise ArgumentError.new('One realm at a time, please') if @realm != path_labels.realm

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
