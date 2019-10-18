class Parser

    def initialize(tokens)
        @tokens = tokens
        @current = 0
    end

    def eof?
        return peek.name == :EOF
    end

    def peek
        return @tokens[@current]
    end

    def previous
        return @tokens[@current - 1]
    end

    def advance
        @current += 1 if !eof?
        return previous
    end

    def check(*types)
        return false if eof?
        return types.include?(peek.name)
    end

    def match_token(*types)
        if check(*types)
            advance
            return true
        end
        return false
    end

    def consume_token(type, error_message="")
        return advance if check(type)
        puts error_message + " Got #{peek}."
        puts previous.origin.join(":")
        exit(1)
        # e = BlossomSyntaxError.new(peek, error_message + " Got #{peek}.")
        # Runner.syntax_error(e)
    end

    def error(token, message)
        puts message
        # e = BlossomParseError.new(token, message)
        # Runner.compile_error(e)
    end

    def escape_string(str)
        escaped = str
        escaped = escaped.gsub('\\n', "\n")
        escaped = escaped.gsub('\\t', "\t")
        escaped = escaped.gsub('\\"', "\"")
        return escaped
    end

    def parse
        statements = []
        while !eof?
            stmt = parse_root
            statements.push(stmt) if !stmt.nil?
        end
        return statements
    end

    def parse_root
        raise "`parse_root` method not yet implemented."
    end

end