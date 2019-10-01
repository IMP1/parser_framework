require 'pp'

require_relative 'example_lexer'
require_relative 'example_parser'

SOURCE = <<-END

if 2+1 < 4 then
    let x : Int = 12
    let y := -1
end

END

lexer = SchwahLexer.new(SOURCE, "foobar.rb::SOURCE")
tokens = lexer.tokenise

pp tokens

parser = SchwahParser.new(tokens)
program = parser.parse

puts
pp program