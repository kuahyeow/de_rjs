module DeRjs
  module Rewriter
    class Erbify < Parser::Rewriter
      class MustTranslateManually < StandardError; end

      def on_send(node)
        receiver_node, method_name, *arg_nodes = *node

        if receiver_node.to_a.last == :page
          case method_name
          when :replace_html, :replace
            rewrite_replace_html(receiver_node, method_name, *arg_nodes)

          when :insert_html
            rewrite_insert_html(receiver_node, method_name, *arg_nodes)

          when :redirect_to
            rewrite_redirect_to(receiver_node, method_name, *arg_nodes)

          when :[]
            rewrite_square_bracket(receiver_node, method_name, *arg_nodes)

          else
            # All others such as :
            # page.alert
            # page.hide
            # page.redirect_to
            # page.reload
            # page.replace
            # page.select
            # page.show
            # page.visual_effect
            rewrite_all_args(receiver_node, method_name, *arg_nodes)
          end
        end

        # page[:html_id].some_method
        if receiver_node.to_a.first.to_a.last == :page && receiver_node.to_a[1] == :[]
          rewrite_square_bracket(*receiver_node.to_a)
          rewrite_square_replace(receiver_node, method_name, *arg_nodes) if [:replace, :replace_html].include?(method_name)
        end
      end

      def rewrite_all_args(receiver_node, method_name, *arg_nodes)
        arg_nodes.each {|arg_node| rewrite_to_erb_unless_static(arg_node) }
      end

      # id, *options_for_render
      def rewrite_replace_html(receiver_node, method_name, *arg_nodes)
        rewrite_to_erb_unless_static(arg_nodes.shift)
        rewrite_options_for_render(arg_nodes)
      end

      # position, id, *options_for_render
      def rewrite_insert_html(receiver_node, method_name, *arg_nodes)
        rewrite_to_erb_unless_static(arg_nodes.shift)
        rewrite_to_erb_unless_static(arg_nodes.shift)
        rewrite_options_for_render(arg_nodes)
      end

      # location (string, or url_for compatible options)
      def rewrite_redirect_to(receiver_node, method_name, *arg_nodes)
        rewrite_url_for(arg_nodes.first)
      end

      # e.g. page["sgfg"] or page["wat_#{@id}"]
      def rewrite_square_bracket(receiver_node, method_name, *arg_nodes)
        rewrite_dom_id(arg_nodes.shift)
      end

      # *options_for_render
      def rewrite_square_replace(receiver_node, method_name, *arg_nodes)
        rewrite_options_for_render(arg_nodes)
      end

      protected
      def rewrite_to_erb_unless_static(id_arg)
        return if [:str, :sym].include?(id_arg.type)
        insert_before id_arg.loc.expression, "%q{<%= "
        insert_after  id_arg.loc.expression, " %>}"
      end

      def rewrite_dom_id(id_arg)
        return if [:str, :sym].include?(id_arg.type)
        if id_arg.type == :dstr || is_dom_id_call?(id_arg)
          insert_before id_arg.loc.expression, "%q{<%= "
          insert_after  id_arg.loc.expression, " %>}"
        else
          insert_before id_arg.loc.expression, "%q{<%= dom_id_or_string("
          insert_after  id_arg.loc.expression, ") %>}"
        end
      end

      def is_dom_id_call?(arg_node)
        array = arg_node.to_a
        array[0..1] == [nil, :dom_id] #&& array.size == 3
      end

      # if Hash, render
      # else assume it's a string
      def rewrite_options_for_render(arg_nodes)
        return if arg_nodes.size == 1 && arg_nodes.first.type == :str
        if arg_nodes.first.type == :hash
          insert_before arg_nodes.first.loc.expression, "%q{<%= escape_javascript(render("
          insert_after  arg_nodes.last.loc.expression, ")) %>}"
        else
          insert_before arg_nodes.first.loc.expression, "%q{<%= escape_javascript("
          insert_after  arg_nodes.last.loc.expression, ") %>}"
        end
      end

      def rewrite_url_for(url_arg)
        return if url_arg.type == :str
        insert_before url_arg.loc.expression, "%q{<%= url_for("
        insert_after  url_arg.loc.expression, ") %>}"
      end
    end
  end
end
