require_relative 'parser'

require_relative 'example_expression'
require_relative 'example_statement'

class SchwahParser < Parser

    def initialize(*args)
        super(*args)
        @in_function = false
        @in_procedure = false
    end

    def parse_root
        stmt = declaration
        return stmt
    end

    def declaration
        # TODO: check for struct / enum / func / proc / variable / etc.
        return statement
    end

    def statement
        if match_token(:LET)
            token = previous
            ident = consume_token(:IDENTIFIER, "Expecting a variable name after the let keyword.")
            consume_token(:COLON, "Expecing ':' in a variable assignment.")
            var_type = nil
            if !match_token(:EQUAL)
                var_type = expression
                consume_token(:EQUAL, "Expecting '=' to create an initial value.")
                # TODO: use var_type to infer type from value
            end
            value = expression
            if var_type.nil?
                var_type = value.type
            end
            return SchawhStatementDeclaration.new(token, ident, var_type, value)
        end
        if match_token(:RETURN)
            return return_statement
        end
        if match_token(:IF)
            return if_statement
        end
        if match_token(:WHILE)
            # TODO: ...
        end
        if match_token(:WHEN)
            # TODO: ...
        end
        return assignment
    end

    def block(*end_tokens)
        if end_tokens.empty?
            end_tokens.push(:END)
        end
        statements = []

        while !eof? && !check(*end_tokens)
            statements.push(declaration)
        end

        return statements
    end

    def return_statement
        token = previous
        value = nil
        if @in_function
            value = expression
        end
        return SchawhStatementReturn.new(token, value)
    end

    def if_statement
        token = previous

        if match_token(:OPEN_PAREN)
            condition = expression
            consume_token(:CLOSE_PAREN, "Expecting ')' after the if statement condition.")
        else
            condition = expression
        end
        consume_token(:THEN, "Expecting 'then' to begin the if statement block.")

        then_keyword = previous
        then_block = block(:ELSE, :END)
        then_branch = SchawhStatementBlock.new(then_keyword, then_block)

        else_branch = nil
        if match_token(:ELSE)
            else_keyword = previous
            else_block = block(:END)
            else_branch = SchawhStatementBlock.new(else_keyword, else_block)
        end

        consume_token(:END, "Expecting 'end' to end the if statement block.")

        return SchawhStatementIf.new(token, condition, then_branch, else_branch)
    end

    def assignment

    end

    def expression
        return short_circuit
    end

    SHORT_CIRCUIT_OPERATORS = [ # In groups in reverse order of precedence
        [ :OR ],
        [ :AND ],
    ]

    def short_circuit(i=0)
        if i >= SHORT_CIRCUIT_OPERATORS.size
            return binary_expression
        end
        expr = short_circuit(i+1)
        while match_token(*SHORT_CIRCUIT_OPERATORS[i])
            op = previous
            right = short_circuit(i+1)
            expr = SchwahExpressionShortCircuit.new(expr, op, right)
        end
        return expr
    end

    BINARY_OPERATORS = [ # In groups in reverse order of precedence
        [ :DOUBLE_EQUAL, :NOT_EQUAL ],
        [ :GREATER, :GREATER_EQUAL, :LESS, :LESS_EQUAL, :BEGINS_WITH, :ENDS_WITH, :CONTAINS ],
        [ :MINUS, :PLUS, :PIPE, :PERCENT ],
        [ :STROKE, :ASTERISK, :AMPERSAND, :DOUBLE_STROKE ],
        [ :CARET ],
    ]

    def binary_expression(i=0)
        if i >= BINARY_OPERATORS.size
            return unary_expression
        end
        expr = binary_expression(i+1)
        while match_token(*BINARY_OPERATORS[i])
            op = previous
            right = binary_expression(i+1)
            type = binary_expression_type(expr, right, op)
            expr = SchwahExpressionBinary.new(expr, op, right, type)
        end
        return expr
    end

    def unary_expression
        if match_token(:NOT, :MINUS, :EXCLAMATION)
            operator = previous
            right = unary_expression
            return SchwahExpressionUnary.new(operator, right)
        end
        return call
    end

    def call
        expr = primary

        loop do
            if match_token(:LEFT_PAREN)
                expr = finish_call(expr)
            elsif match_token(:DOT)
                field = consume_token(:IDENTIFIER, "Expecting property name after '.'.")
                expr = SchwahExpressionProperty.new(expr, field)
            else
                break
            end
        end

        return expr
    end

    def finish_call(callee)
        args = []
        if !check(:RIGHT_PAREN)
            loop do
                args.push(expression)
                break if !match_token(:COMMA)
            end
        end
        paren = consume_token(:RIGHT_PAREN, "Expecting ')' after arguments.")
        return SchwahExpressionCall.new(callee, paren, args)
    end

    def primary
        if match_token(:TYPE_LITERAL)
            return type_literal(previous, previous.literal)
        end
        if match_token(:BOOLEAN_LITERAL)
            type = type_literal(previous, :boolean)
            return SchwahExpressionLiteral.new(previous, previous.literal, type)
        end
        if match_token(:INTEGER_LITERAL, :RATIONAL_LITERAL, :DECIMAL_LITERAL)
            return number(previous)
        end
        # ...

        if match_token(:IDENTIFIER)
            return SchwahExpressionVariable.new(previous)
        end

        raise "Expecting an expression. Got '#{peek.lexeme}'."
    end

    def number(token)
        type_name = case token.name
        when :INTEGER_LITERAL
            :integer
        when :RATIONAL_LITERAL
            :rational
        when :DECIMAL_LITERAL
            :decimal
        end
        return SchwahExpressionLiteral.new(token, token.literal, type_literal(token, type_name))
    end

    def type_literal(token, type_name)
        type = case type_name
        when :boolean
            SchwahType::Boolean.new
        when :integer
            SchwahType::Integer.new
        end
        return SchwahExpressionType.new(token, type)
    end

    def binary_expression_type(left, right, operator)
        # TODO: this needs to depend on the types of left (and right)
        # TODO: this will probably need to be more complicated if operators can be defined on types
        return case operator.name
        when :GREATER, :GREATER_EQUAL, :LESS, :LESS_EQUAL, :BEGINS_WITH, :ENDS_WITH, :CONTAINS, :DOUBLE_EQUAL, :NOT_EQUAL
            type_literal(operator, :boolean)
        when :MINUS, :PLUS, :PIPE, :PERCENT, :STROKE, :ASTERISK, :AMPERSAND, :DOUBLE_STROKE, :CARET
            left.type
        else
            nil
        end
    end

end