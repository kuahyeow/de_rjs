require 'parser/current'
require_relative 'erbify'

module Rewriter
  def rewrite_rjs(source)
    buffer = Parser::Source::Buffer.new("buffer_name")
    buffer.source = source
    parser = Parser::CurrentRuby.new
    ast = parser.parse(buffer)
    rewriter = Erbify.new

    rewriter.rewrite(buffer, ast)
  end
  module_function :rewrite_rjs
end
