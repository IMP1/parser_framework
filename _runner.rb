require_relative 'nand_lexer'
require_relative 'nand_parser'
require_relative 'nand_runner'

def run(source, ticks=nil)
    lexer = NandLexer.new(source)
    tokens = lexer.tokenise

    parser = NandParser.new(tokens)
    program = parser.parse

    runner = NandRunner.new(program)
    runner.run(ticks)
end

def main(filename)
    run(File.read(filename))
end

filename = ARGV[0]
ticks = ARGV[1]

if !filename.nil?
    main(filename, ticks)
end

SOURCE = <<-END

let clock() = [ |x: nand|
    x(x, 0)
]

clock()

END

run(SOURCE, 2)