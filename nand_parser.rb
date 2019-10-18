require_relative 'parser'

require_relative 'nand_expression'
require_relative 'nand_statement'

class NandParser < Parser

    def initialize(*args)
        super(*args)
    end

    def parse_root
        return statement
    end

    def statement
        if match_token(:IMPORT)
            raise "Import not yet implemented. Sorry!"
            token = previous
            path = consume_token(:IDENTIFIER, "Expecting a variable name after the let keyword.")
        elsif match_token(:DEF)
            token = previous
            ident = consume_token(:IDENTIFIER, "Expecting a variable name after the let keyword.")
            consume_token(:OPEN_PAREN, "Expecing '(' to begin parameter list.")
            params = []
            while !check(:CLOSE_PAREN)
                params.push(consume_token(:IDENTIFIER, "Expecting either a parameter name, or the end of the list."))
                break if !match_token(:COMMA)
            end
            consume_token(:CLOSE_PAREN, "Expecting ')' to end parameter list.")
            value = expression
            if value.is_a?(NandExpressionComposite)
                value.params = params.map { |param| NandExpressionVariable.new(param.lexeme) }
            end
            return NandStatementAssignment.new(token, ident, value)
        elsif match_token(:LET)
            token = previous
            ident = consume_token(:IDENTIFIER, "Expecting a variable name after the let keyword.")
            consume_token(:EQUAL, "Expecting '=' as part of assignment")
            value = expression
            if value.is_a?(NandExpressionComposite)
                value.params = params.map { |param| NandExpressionVariable.new(param.lexeme) }
            end
            return NandStatementAssignment.new(token, ident, value)
        elsif match_token(:OUTPUT)
            token = previous
            values = []
            loop do
                values.push(expression)
                break if !match_token(:COMMA)
            end
            return NandStatementOutput.new(token, values)
        end
        return NandStatementCall.new(call)
    end

    def expression
        return call
    end

    def call
        expr = primary

        if match_token(:LEFT_PAREN)
            expr = finish_call(expr)
        end

        return expr
    end

    def finish_call(callee)
        args = []
        while !check(:RIGHT_PAREN)
            args.push(expression)
            break if !match_token(:COMMA)
        end
        consume_token(:RIGHT_PAREN, "Expecting ')' after arguments.")
        return NandExpressionCall.new(callee, args)
    end

    def primary
        if match_token(:OPEN_SQUARE)
            return composite_object
        end
        if check(:IDENTIFIER)
            return simple_object
        end
        raise "Expecting an expression. Got '#{peek.lexeme}'."
    end

    def composite_object
        start = previous
        body = []
        while !eof? && !check(:CLOSE_SQUARE)
            body.push(statement)
        end
        consume_token(:CLOSE_SQUARE, "Expecting ']' to end composite object.")
        return NandExpressionComposite.new(start, [], body)
    end

    def simple_object
        if match_token(:LIVE)
            return NandExpressionLive.new(previous)
        end
        if match_token(:GROUND)
            return NandExpressionGround.new(previous)
        end
        ident = consume_token(:IDENTIFIER, "Expecting a valid identifier.")
        if match_token(:OPEN_PAREN, "Expecting '(' to begin parameter list.")
            args = []
            while !check(:CLOSE_PAREN)
                args.push(simple_object)
                break if !match_token(:COMMA)
            end
            consume_token(:CLOSE_PAREN, "Expecting ')' to end parameter list.")
            return NandExpressionSimple.new(ident, args)
        else
            return NandExpressionVariable.new(ident)
        end
    end

end