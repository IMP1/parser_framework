require_relative 'token'

class Token

    def self.system(lexeme)
        return Token.new(:SYSTEM_FUNCTION, lexeme, 0, 0, "System")
    end

end