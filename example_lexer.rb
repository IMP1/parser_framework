require_relative 'lexer'

class SchwahLexer < Lexer

    KEYWORDS = {
        'if'     => :IF,
        'then'   => :THEN,
        'while'  => :WHILE,
        'do'     => :DO,
        'else'   => :ELSE,
        'when'   => :WHEN,
        'is'     => :IS,
        'end'    => :END,
        'return' => :RETURN,

        'or'  => :OR,
        'and' => :AND,

        'let'    => :LET,
    }

    VALUE_KEYWORDS = {
        # Language Constants
        'TRUE'  => [:BOOLEAN_LITERAL, true],
        'FALSE' => [:BOOLEAN_LITERAL, false],
        'NULL'  => [:OPTIONAL_LITERAL, nil],

        # System Typess
        'Any'      => [:TYPE_LITERAL, :any],
        'Boolean'  => [:TYPE_LITERAL, :boolean],
        'Bool'     => [:TYPE_LITERAL, :boolean],
        'Integer'  => [:TYPE_LITERAL, :integer],
        'Int'      => [:TYPE_LITERAL, :integer],
        'Rational' => [:TYPE_LITERAL, :rational],
        'Rat'      => [:TYPE_LITERAL, :rational],
        'Decimal'  => [:TYPE_LITERAL, :decimal],
        'Real'     => [:TYPE_LITERAL, :decimal],
        'String'   => [:TYPE_LITERAL, :string],
        'Array'    => [:TYPE_LITERAL, :array],
        'List'     => [:TYPE_LITERAL, :list],
        'Set'      => [:TYPE_LITERAL, :set],
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
        when '{'
            add_token(:OPEN_BRACE)
        when '}'
            add_token(:CLOSE_BRACE)
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
        when ':'
            if advance_if(':')
                add_token(:DOUBLE_COLON)
            else
                add_token(:COLON)
            end

        #---
        # Operators
        #---
        when '+'
            add_token(:PLUS)
        when '-'
            if advance_if('-') and advance_if('-')
                add_token(:UNINITIALISED)
            else
                add_token(:MINUS)
            end
        when '*'
            add_token(:ASTERISK)
        when '%'
            add_token(:PERCENT)
        when '&'
            if advance_if('&')
                add_token(:DOUBLE_AMPERSAND)
            else
                add_token(:AMPERSAND)
            end
        when '|'
            if advance_if('|')
                add_token(:DOUBLE_PIPE)
            else
                add_token(:PIPE)
            end
        when '?'
            if advance_if('?')
                add_token(:DOUBLE_QUESTION)
            else
                add_token(:QUESTION)
            end
        when '/'
            if advance_if('/')
                add_token(:DOUBLE_STROKE)
            else
                add_token(:STROKE)
            end
        when '<'
            if advance_if('=')
                add_token(:LESS_OR_EQUAL)
            else
                add_token(:LESS)
            end
        when '>'
            if advance_if('=')
                add_token(:GREATER_OR_EQUAL)
            else
                add_token(:GREATER)
            end
        when '^'
            if advance_if('=')
                add_token(:BEGINS_WITH)
            else
                add_token(:CARET)
            end
        when '$'
            if advance_if('=')
                add_token(:ENDS_WITH)
            else
                add_token(:DOLLAR)
            end
        when '~'
            if advance_if('=')
                add_token(:CONTAINS)
            else
                add_token(:TILDE)
            end
        when '='
            if advance_if('=')
                add_token(:DOUBLE_EQUAL)
            else
                add_token(:EQUAL)
            end
        when '!'
            if advance_if('=')
                add_token(:NOT_EQUAL)
            else
                add_token(:EXCLAMATION)
            end

        #---
        # Literals
        #---
        when /\d/
            number
        when '"'
            string


        when /\w/ # /\p{Letter}/
            word

        else
            puts "Unrecognised character: '#{previous}'."
        end

    end

    def number
        advance while peek =~ /[\d_]/
        if peek == '.' && peek_next =~ /\d/
            advance
            advance while peek =~ /\d/
            add_token(:DECIMAL_LITERAL, @source[@start...@current].gsub("_", "").to_f)
        elsif peek == '/' && peek_next =~ /\d/
            advance
            advance while peek =~ /\d/
            add_token(:RATIONAL_LITERAL, @source[@start...@current].gsub("_", "").to_r)
        else
            add_token(:INTEGER_LITERAL, @source[@start...@current].gsub("_", "").to_i)
        end
    end

    def string
        string_start = [@line, @column]
        while !eof? && !(peek == '"' && previous != "\\")
            newline if peek == "\n"
            advance
        end

        if eof?
            puts "Unterminated string starting at line:column #{string_start.join(":")}" 
            return
        end

        # The closing ".
        advance
        # Trim the surrounding quotes.
        value = @source[@start + 1...@current - 1]
        add_token(:STRING_LITERAL, value)
    end

    def word
        advance while peek() =~ /\w/

        text = @source[@start...@current]

        # See if the identifier is a reserved word.
        if VALUE_KEYWORDS.has_key?(text)
            type  = VALUE_KEYWORDS[text][0]
            value = VALUE_KEYWORDS[text][1]
            add_token(type, value)
            return
        end

        # See if the identifier is a type.
        type = :IDENTIFIER
        type = KEYWORDS[text] if KEYWORDS.has_key?(text)

        add_token(type)
    end

end