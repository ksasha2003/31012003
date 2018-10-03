# frozen_string_literal: true

require "rubocop"

module RuboCop
  module Cop
    module GitHub
      # The string passed to `render inline:` is compiled by ERB each time the method is called.
      #
      # This can lead to a memory leak: https://github.com/rails/rails/issues/33019#issuecomment-409379676
      #
      # To avoid a memory leak, either:
      #
      # - use `render plain: ...` to render plain text (no ERB); OR
      # - extract the ERB into a template file and render that template.
      class RailsRenderInline < Cop
        MSG = <<~MSG
Instead of `render inline:`, which can have memory leaks,
use `render plain: "..."` for plain text, or extract a template for ERB.
MSG

        def_node_matcher :render_with_options?, <<-PATTERN
          (send nil? :render (hash $...))
        PATTERN

        def_node_matcher :inline_key?, <<-PATTERN
          (pair (sym :inline) $_)
        PATTERN

        def on_send(node)
          if option_pairs = render_with_options?(node)
            if option_pairs.detect { |pair| inline_key?(pair) }
              add_offense(node, location: :expression)
            end
          end
        end
      end
    end
  end
end
