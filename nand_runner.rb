require 'pp'

require_relative 'visitor'
require_relative 'token'
require_relative 'nand_environment'

class NandRunner < Visitor

    TICK_DELAY = 0.5

    def initialize(statements)
        @statements = statements
        @current_tick = 0
        @last_update = {}
        @last_value = {}
        @queues = {}
        @output_target = $stdout
        setup_system_scope
        push_scope("global")
    end

    def setup_system_scope
        @environment = nil
        push_scope("system")
        sys_token = Token.new(:SYSTEM, "nand", 0, 0, "sys.nand")
        @environment["nand"] = NandExpressionNand.new(sys_token)
    end

    def run(ticks=nil)
        return if @statements.empty?
        loop do
            begin
                @statements.each do |stmt|
                    execute(stmt)
                    @current_tick += 1
                end
                $stdout.flush
                ticks -= 1 unless ticks.nil?
                break if ticks == 0
                sleep(TICK_DELAY)
            rescue SignalException => e
                break
            end
        end
    end

    def constant?(expr)
        return case expr
        when NandExpressionLive
            true
        when NandExpressionGround
            true
        else
            false
        end
    end

    def push_scope(env_name)
        new_environment = NandEnvironment.new(env_name, @environment)
        @environment = new_environment
        puts "Entering new scope (#{env_name})"
    end

    def pop_scope
        puts "Leaving scope (#{@environment.name})"
        new_environment = @environment.parent
        @environment = new_environment
    end

    def with_scope(env_name, &block)
        old_environment = @environment
        @environment = NandEnvironment.new(env_name, old_environment)
        result = block.call
        @environment = @environment.parent
        return result
    end

    def with_output(output_target, &block)
        old_target = @output_target
        @output_target = output_target
        result = block.call
        @output_target = old_target
        return result
    end

    def execute(stmt)
        return stmt.accept(self)
    end

    def evaluate(expr)
        return expr.accept(self)
    end

    def dereference(var_expr)
        while var_expr.is_a?(NandExpressionVariable)
            var_expr = @environment[var_expr.name.lexeme]
        end
        return var_expr
    end

    def visit_NandStatementAssignment(stmt)
        puts "Assignment"
        @environment[stmt.name.lexeme] = stmt.value
        # TODO: create instance here
    end

    def visit_NandStatementDefinition(stmt)
        puts "Definition"
        @environment[stmt.name.lexeme] = stmt.value
    end

    def visit_NandStatementOutput(stmt)
        puts "Output"
        @output_target << stmt.values.map { |val| evaluate(val) }.flatten
    end

    def visit_NandExpressionCall(expr)
        # TODO: Rethink this from ground up.
        puts "Call"
        callee = evaluate(expr.callee)
        puts "Callee: "
        p callee
        p callee.outputs
        args = expr.inputs.map { |input| evaluate(input) }.flatten
        with_scope(expr.token.lexeme) do
            callee.inputs.each_with_index { |param, i| puts "#{param.lexeme} => #{args[i]}"; @environment[param.lexeme] = args[i] }
            callee.sub_components.each { |key, value| puts "#{key} => #{value}"; @environment[key] = value }
            result = []
            with_output(result) { callee.outputs.each { |output| output.call() } }
            puts "result: #{result.inspect}"
            result
        end
    end

    def visit_NandExpressionLive(expr)
        return [true]
    end

    def visit_NandExpressionGround(expr)
        return [false]
    end

    def visit_NandExpressionVariable(expr)
        puts "Variable (#{expr.name.lexeme})"
        p expr
        return evaluate(@environment[expr.name.lexeme])
    end

    def visit_NandExpressionNand(expr)
        # TODO: Rethink this from ground up.
        puts "Nand"
        p expr
        token = expr.token
        inputs = expr.inputs
        puts "Inputs: #{inputs.inspect}"
        sub_components = expr.sub_components
        # TODO: what should output functions be?
        output_functions = expr.outputs.map do |output|
            ->() { nand(output) }
        end
        instance = NandExpressionComponentInstance.new(token, inputs, sub_components, output_functions)
        return instance
    end

    def visit_NandExpressionComponentBlueprint(expr)
        # TODO: Rethink this from ground up.
        puts "Blueprint"
        # TODO: create instance
        token = expr.token
        inputs = expr.inputs
        puts "Inputs: #{inputs.inspect}"
        sub_components = expr.sub_components
        # TODO: what should output functions be?
        output_functions = expr.outputs.map do |output|
            ->() { evaluate(output) }
        end
        instance = NandExpressionComponentInstance.new(token, inputs, sub_components, output_functions)
        return instance
    end

    def visit_NandExpressionComponentInstance(expr)
        # TODO: Rethink this from ground up.
        puts "Instance"
        expr
    end

end

# TODO: four methods need fixing. They're the four that are the closest to the actual implementation of the language:

# ComponentBlueprint is what's created in a definition.
# ComponentInstance is what's created in a let statement, and in output statements.
# Nand is the base of everything. The only component with a concrete output method
# Call needs to work out what's being called, and what the arguments are, and pass the arguments to the callee.
