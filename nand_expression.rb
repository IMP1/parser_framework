require_relative 'visitor'

class Expression
    include Visitable

    attr_reader :token

    def initialize(token)
        @token = token
    end

end

class NandExpressionCall < Expression

    attr_reader :callee
    attr_reader :params

    def initialize(callee, params)
        super(callee.token)
        @callee = callee
        @params = params
    end

end

class NandExpressionLive < Expression
end

class NandExpressionGround < Expression
end

class NandExpressionComposite < Expression

    attr_reader :params
    attr_reader :objects

    def initialize(start, params, objects)
        super(start)
        @params = params
        @objects = objects
    end

end

class NandExpressionSimple < Expression

    attr_reader :name
    attr_reader :params

    def initialize(token, params)
        super(token)
        @name = token.lexeme
        @params = params
    end

end

class NandExpressionVariable < Expression

    attr_reader :name

    def initialize(var_name)
        super(var_name)
        @name = var_name
    end

end

