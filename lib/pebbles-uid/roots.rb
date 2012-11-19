module Pebbles
  class Uid
    def self.root_paths(uids)
      paths = uids.map { |uid| Labels.new(Pebbles::Uid.path(uid)) }
      roots = [paths.first]
      paths[1..-1].each { |path|
        roots.each { |root|
          roots << path unless root.parent_of?(path)
        }
      }
      roots.map(&:to_s)
    end
  end
end
