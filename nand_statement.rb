require_relative 'visitor'

class Statement
    include Visitable

    attr_reader :token

    def initialize(token)
        @token = token
    end

end

class NandStatementAssignment < Statement

    attr_reader :name
    attr_reader :value

    def initialize(keyword, var_name, value)
        super(keyword)
        @name = var_name
        @value = value
    end

end

class NandStatementOutput < Statement

    attr_reader :values

    def initialize(keyword, values)
        super(keyword)
        @values = values
    end

end

class NandStatementCall < Statement

    attr_reader :value

    def initialize(value)
        super(value.token)
        @value = value
    end

end