require_relative 'lexer'

class NandLexer < Lexer

    KEYWORDS = {
        'def'    => :DEF,
        'let'    => :LET,
        'in'     => :INPUT,
        'out'    => :OUTPUT,
        'import' => :IMPORT,
        'end'    => :END,
    }

    def scan_token
        char = advance

        case char

        #---
        # Whitespace
        #---
        when ' ', "\r", "\t"
            # do nothing
        when "\n"
            newline

        #---
        # Brackets
        #---
        when '('
            add_token(:OPEN_PAREN)
        when ')'
            add_token(:CLOSE_PAREN)
        when '['
            add_token(:OPEN_SQUARE)
        when ']'
            add_token(:CLOSE_SQUARE)

        #---
        # Comments
        #---
        when "#"
            while !eof? && peek != "\n"
                advance
            end

        #---
        # Brackets
        #---
        when ','
            add_token(:COMMA)

        #---
        # Operators
        #---
        when '='
            add_token(:EQUAL)

        #---
        # Literals
        #---
        when '0'
            add_token(:GROUND)
        when '1'
            add_token(:LIVE)

        when /\w/ # /\p{Letter}/
            word

        else
            puts "Unrecognised character: '#{previous}'."
        end

    end

    def word
        advance while peek() =~ /\w/

        text = @source[@start...@current]
        type = KEYWORDS.has_key?(text) ? KEYWORDS[text] : :IDENTIFIER

        add_token(type)
    end

end