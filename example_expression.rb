require_relative 'visitor'
require_relative 'example_type'

class Expression
    include Visitable

    attr_reader :type
    attr_reader :token

    def initialize(token, type)
        @token = token
        @type  = type
    end

end

class SchwahExpressionBinary < Expression

    attr_reader :operator
    attr_reader :left
    attr_reader :right

    def initialize(left, operator, right, type=nil)
        super(operator, type || left.type)
        @left = left
        @operator = operator
        @right = right
    end

end

class SchwahExpressionShortCircuit < SchwahExpressionBinary

    def initialize(left, operator, right, type=nil)
        super(left, operator, right, left.type == right.type ? left.type : SchwahType::Union(left.type, right.type))
    end

end

class SchwahExpressionUnary < Expression

    attr_reader :operator
    attr_reader :right

    def initialize(operator, right, type=nil)
        super(operator, type || right.type)
        @operator = operator
        @right = right
    end

end

class SchwahExpressionProperty < Expression

    attr_reader :object
    attr_reader :field

    def initialize(object, field, type=nil)
        super(field, type)
        @object = object
        @field = field
    end

end

class SchwahExpressionCall < Expression

    attr_reader :callee
    attr_reader :token
    attr_reader :arguments

    def initialize(callee, token, arguments, type=nil)
        super(token, type)
        @callee = callee
        @token = token
        @arguments = arguments
    end

end

class SchwahExpressionVariable < Expression

    attr_reader :name

    def initialize(var_name, type=nil)
        super(var_name, type)
        @name = var_name
    end

end

class SchwahExpressionLiteral < Expression

    attr_reader :value

    def initialize(token, value, type)
        super(token, type)
        @value = value
    end

end

class SchwahExpressionType < Expression

    attr_reader :value

    def initialize(token, type)
        super(token, SchwahType::Type)
        @type = type
    end

end