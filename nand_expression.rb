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
    attr_reader :body

    def initialize(start, params, body)
        super(start)
        @params = params
        @body = body
    end

    def params=(new_params)
        @params = new_params
    end

end

class NandExpressionObject < Expression

    attr_reader :name
    attr_reader :object

    def initialize(token, object)
        super(token)
        @name = token.lexeme
        @object = object
    end

end

class NandExpressionReference < Expression

    attr_reader :name

    def initialize(token)
        super(token)
        @name = token.lexeme
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

