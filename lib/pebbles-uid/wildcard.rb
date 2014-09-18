module Pebbles
  class Uid
    module Wildcard

      class << self

        def valid?(path)
          path &&
            stars_are_solitary?(path) &&
            single_caret?(path) &&
            pipes_are_interleaved?(path) &&
            carets_are_leading?(path) &&
            stars_are_terminating?(path)
        end

        # a.*.c passes
        # a.*b.c does not
        # A later rule ensures that * always falls at the end of a path
        def stars_are_solitary?(path)
          !path.split('.').any? {|s| s.match(/.+\*|\*.+/)}
        end

        # a.b|c.d passes
        # a.|b.c does not
        def pipes_are_interleaved?(path)
          !path.split('.').any? {|s| s.match(/^\||\|$/)}
        end

        # a.^b.c passes
        # a.^c.^d does not
        def single_caret?(path)
          path.split('.').select {|s| s.match(/\^/) }.size <= 1
        end

        # a.^b.c passes
        # a.b^c.d does not
        def carets_are_leading?(path)
          !path.split('.').any? {|s| s.match(/.+\^|\^$/) }
        end

        # a.b.* passes
        # *.b.c does not
        def stars_are_terminating?(path)
          path !~ /.*\*\.\w/
        end

      end
    end
  end
end
