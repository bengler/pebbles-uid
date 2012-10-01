module Pebbles
  class Uid
    class Query

      attr_reader :term, :terms
      def initialize(term)
        @term = term

        if wildcard_query?
          @terms = [term]
          _, path, _ = Pebbles::Uid.parse(term)
          raise ArgumentError.new('Realm must be specified') unless Path.new(path).realm?
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

      private

      def wildcard_query?
        return false if term.include?(',')
        _, _, oid = Pebbles::Uid.parse(term)
        return true if oid.nil? || oid.empty? || oid == '*'
        false
      end

      def extract_terms
        term.split(',').map do |uid|
          species, path, oid = Pebbles::Uid.parse(uid)
          species_labels = Species.new(species)
          path_labels = Path.new(path)
          oid_box = Oid.new(oid)

          raise ArgumentError.new('Realm must be specified') unless path_labels.realm?
          raise ArgumentError.new('Species must unambiguous') if species_labels.ambiguous?
          raise ArgumentError.new('Oid must be unambiguous') if oid_box.ambiguous?

          @realm ||= path_labels.realm
          raise ArgumentError.new('One realm at a time, please') if @realm != path_labels.realm

          if oid_box.multiple?
            oid.split('|').map do |s|
              "#{species}:#{path}$#{s}"
            end
          else
            uid
          end
        end.flatten
      end



    end
  end
end
