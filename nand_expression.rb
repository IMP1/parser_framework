require_relative 'visitor'
require_relative 'token'

class Expression
    include Visitable

    attr_reader :token

    def initialize(token)
        @token = token
    end

end

class NandExpressionCall < Expression

    attr_reader :callee
    attr_reader :inputs

    def initialize(callee, inputs)
        super(callee.token)
        @callee = callee
        @inputs = inputs
    end

end

class NandExpressionLive < Expression
end

class NandExpressionGround < Expression
end

class NandExpressionComponent < Expression

    attr_reader :inputs
    attr_reader :sub_components
    attr_reader :outputs

    def initialize(start, inputs, sub_components, outputs)
        super(start)
        @inputs = inputs
        @sub_components = sub_components
        @outputs = outputs
    end

    def inputs=(new_inputs)
        @inputs = new_inputs
    end

end

class NandExpressionReference < Expression

    attr_reader :name

    def initialize(token)
        super(token)
        @name = token.lexeme
    end

end

class NandExpressionVariable < Expression

    attr_reader :name

    def initialize(var_name)
        super(var_name)
        @name = var_name
    end

end

class NandExpressionNand < Expression

    attr_reader :inputs
    attr_reader :sub_components
    attr_reader :outputs

    def initialize(token)
        super(token)
        @inputs = [Token.new(:IDENTIFIER, "a", 0, 0, "sys.nand"), Token.new(:IDENTIFIER, "b", 0, 0, "sys.nand")]
        @sub_components = []
        @outputs = []
    end

end

class NandExpressionComponentInstance < Expression

    attr_reader :inputs
    attr_reader :sub_components
    attr_reader :outputs

    def initialize(token, inputs, sub_components, outputs)
        super(token)
        @inputs = inputs
        @sub_components = sub_components
        @outputs = outputs
        @last_update = nil
        @last_value = nil
    end

    def update(tick)
        return @last_value if tick == @last_update

        result = outputs.map { |func| func.call }

        @last_update = tick
        @last_value = result
        return result
    end

end

class NandExpressionComponentBlueprint < Expression

    attr_reader :inputs
    attr_reader :sub_components
    attr_reader :outputs

    def initialize(token, inputs, sub_components, outputs)
        super(token)
        @inputs = inputs
        @sub_components = sub_components
        @outputs = outputs
    end

end