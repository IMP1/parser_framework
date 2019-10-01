class Token

    attr_reader :name
    attr_reader :lexeme
    attr_reader :origin
    attr_reader :literal

    def initialize(name, lexeme, line, column, filename, literal=nil)
        @name     = name
        @lexeme   = lexeme
        @origin   = [filename, line, column]
        @literal  = literal
    end

    def to_s
        return @name.to_s + " '" + @lexeme + "' " + (@literal.nil? ? "" : @literal.to_s)
    end

end