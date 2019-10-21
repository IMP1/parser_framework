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
            token = previous
            path = consume_token(:IDENTIFIER, "Expecting a variable name after the let keyword.")
            raise "Import not yet implemented. Sorry!" # TODO: implement imports
        elsif match_token(:DEF)
            return definition
        elsif match_token(:LET)
            return assignment
        elsif match_token(:OUTPUT)
            return output
        end
        raise "Unrecognised statement: #{peek}"
    end

    def definition
        keyword = previous
        ident = consume_token(:IDENTIFIER, "Expecting a variable name after the let keyword.")
        inputs = []
        sub_components = {}
        outputs = []
        while !check(:END)
            if match_token(:INPUT)
                if match_token(:OPEN_SQUARE)
                    while !check(:CLOSE_SQUARE)
                        inputs.push(consume_token(:IDENTIFIER, "Expecting either an input name, or the end of the list."))
                        break if !match_token(:COMMA)
                    end
                    consume_token(:CLOSE_SQUARE, "Expecting ']' to close the input list.")
                else
                    inputs.push(consume_token(:IDENTIFIER, "Expecting an input name."))
                end
            elsif match_token(:LET)
                sub_components.push(assignment)
            elsif match_token(:OUTPUT)
                outputs.push(output)
            else
                raise "Unrecognised statement in component definition: #{peek}"
            end
        end
        consume_token(:END, "Expecting 'end' to close component definition.")
        new_component = NandExpressionComponentBlueprint.new(ident, inputs, sub_components, outputs)
        return NandStatementDefinition.new(keyword, ident, new_component)
    end

    def assignment
        token = previous
        ident = consume_token(:IDENTIFIER, "Expecting a variable name after the let keyword.")
        consume_token(:EQUAL, "Expecting '=' as part of assignment")
        value = primary
        return NandStatementAssignment.new(token, ident, value)
    end

    def output
        token = previous
        outputs = []
        if match_token(:OPEN_SQUARE)
            while !check(:CLOSE_SQUARE)
                outputs.push(expression)
                break if !match_token(:COMMA)
            end
            consume_token(:CLOSE_SQUARE, "Expecting ']' to close the output list.")
        else
            outputs.push(expression)
        end
        return NandStatementOutput.new(token, outputs)
    end

    def expression
        expr = primary

        if match_token(:OPEN_PAREN)
            expr = finish_call(expr)
        end

        return expr
    end

    def finish_call(callee)
        args = []
        while !check(:CLOSE_PAREN)
            args.push(expression)
            break if !match_token(:COMMA)
        end
        consume_token(:CLOSE_PAREN, "Expecting ')' after arguments.")
        return NandExpressionCall.new(callee, args)
    end

    def primary
        if match_token(:LIVE)
            return NandExpressionLive.new(previous)
        end
        if match_token(:GROUND)
            return NandExpressionGround.new(previous)
        end
        ident = consume_token(:IDENTIFIER, "Expecting a valid identifier.")
        if ident == "nand"
            return NandExpressionNand.new(ident)
        else
            return NandExpressionVariable.new(ident)
        end
    end

end