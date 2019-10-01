require_relative 'visitor'
require_relative 'example_type'

class Statement
    include Visitable

    attr_reader :token

    def initialize(token)
        @token = token
    end

end

class SchawhStatementDeclaration < Statement

    attr_reader :name
    attr_reader :type
    attr_reader :initial_value

    def initialize(keyword, var_name, type, initial_value)
        super(keyword)
        @name = var_name
        @type = type
        @initial_value = initial_value
    end

end

class SchawhStatementBlock < Statement

    attr_reader :statements

    def initialize(keyword, statements)
        super(keyword)
        @statements = statements
    end

end

class SchawhStatementReturn < Statement

    attr_reader :value

    def initialize(keyword, value)
        super(keyword)
        @value = value
    end

end

class SchawhStatementIf < Statement

    attr_reader :keyword
    attr_reader :condition
    attr_reader :then_branch
    attr_reader :else_branch

    def initialize(keyword, condition, then_branch, else_branch)
        super(keyword)
        @keyword = keyword
        @condition = condition
        @then_branch = then_branch
        @else_branch = else_branch
    end

end
