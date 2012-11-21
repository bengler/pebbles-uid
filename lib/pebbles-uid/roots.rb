module Pebbles
  class Uid
    class Roots

      attr_reader :paths
      def initialize(uids)
        @paths = {}
        uids.each { |uid|
          @paths[uid] = Labels.new(Pebbles::Uid.path(uid))
        }
      end

      def unique
        unless @unique
          @unique = []
          paths.each do |uid, path|
            unless paths.any? { |_, other| path.child_of?(other) }
              @unique << uid
            end
          end
        end
        @unique
      end

    end
  end
end
