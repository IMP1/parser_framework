require_relative 'token'

class Lexer

    def initialize(source, origin="")
        @source = source
        @origin = origin

        @tokens  = []
        @start   = 0
        @current = 0
        @line    = 1
        @column   = 1
    end

    def tokenise
        while !eof?
            @start = @current
            scan_token
        end
        @tokens.push(Token.new(:EOF, "", @line, @column, @origin))
        return @tokens
    end

    def scan_token
        raise "`scan_token` method not yet implemented."
    end

    def add_token(token_type, literal_value=nil)
        lexeme = @source[@start...@current]
        token = Token.new(token_type, lexeme, @line, @column, @origin, literal_value)
        @tokens.push(token)
    end

    def eof?
        return @current >= @source.length
    end

    def newline
        @line += 1
        @column = 1
    end

    def advance
        @current += 1
        @column += 1
        return previous
    end

    def advance_if(expected)
        return false if eof?
        return false if peek != expected
        advance
        return true
    end

    def previous
        return @source[@current - 1]
    end

    def peek(n=0)
        return nil if eof?
        return @source[@current+n]
    end

end