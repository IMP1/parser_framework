require_relative 'visitor'

class NandRunner < Visitor

    TICK_DELAY = 0.5

    def initialize(statements)
        @statements = statements
        @environment = {}
        @current_tick = 0
        @last_update = {}
        @last_value = {}
        @queues = {}
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

    def simple_entity(expr)
        puts "Simple Entity"
        puts expr.name
        arg_count = expr.params.size
        param_count = @environment[expr.name].params.reject { |param| constant?(param) }.size
        raise "Wrong number of arguments" if arg_count != param_count
        args = expr.params.map { |arg| evaluate(arg) }
        old_variables = {} # TODO: push scope
        @environment[expr.name].params.each_with_index do |param, i|
            old_variables[param.name.lexeme] = @environment[param.name.lexeme]
            @environment[param.name.lexeme] = args[i]
        end
        puts "#{expr.name} => #{@environment[expr.name].name}"
        result = evaluate(@environment[expr.name]) # TODO: map parameters/arguments across
        old_variables.each do |key, value|  # TODO: pop scope
            if value.nil?
                @environment.delete(key)
            else
                @environment[key] = value
            end
        end
        return result
    end

    def composite_entity(expr)
        puts "Composite Entity"
        composite = @environment[expr.name]
        params = composite.params
        args = params.map.with_index { |param, i| [param.name, evaluate(expr.params[i])] }.to_h
        # TODO: push a scope?
        composite.body.each do |stmt|
            execute(stmt)
        end
        # TODO: pop a scope?
        puts
    end

    def execute(stmt)
        return stmt.accept(self)
    end

    def evaluate(expr)
        return expr.accept(self)
    end

    def visit_NandStatementAssignment(stmt)
        puts "Assignment"
        @environment[stmt.name.lexeme] = stmt.value
    end

    def visit_NandStatementCall(stmt)
        puts evaluate(stmt.value) ? 1 : 0
    end

    def visit_NandStatementOutput(stmt)
        puts "Output"
        p stmt.values.map { |val| evaluate(val) }
        puts "---"
    end

    def visit_NandExpressionCall(expr)
        puts "Call"
        p expr
    end

    def visit_NandExpressionLive(expr)
        return true
    end

    def visit_NandExpressionGround(expr)
        return false
    end

    def visit_NandExpressionComposite(expr)
        puts "Composite"
    end

    def visit_NandExpressionSimple(expr)
        puts "Simple"
        puts expr.name
        case expr.name
        when "nand"
            raise "Wrong number of arguments" if expr.params.size != 2

            @last_update[expr] ||= @current_tick - 1
            @last_value[expr] ||= 0
            return @last_value[expr] if @last_update[expr] == @current_tick

            a = evaluate(expr.params[0])
            b = evaluate(expr.params[1])
            result = !(a && b)

            @last_update[expr] = @current_tick
            @last_value[expr] = result
            return result

        when "delay"
            raise "Wrong number of arguments" if expr.params.size != 1

            @last_update[expr] ||= @current_tick - 1
            @last_value[expr] ||= 0
            @queues[expr] ||= [nil]
            return @last_value[expr] if @last_update[expr] == @current_tick

            a = evaluate(expr.params[0])
            @queues[expr].push(a)
            result = @queues.shift

            @last_update[expr] = @current_tick
            @last_value[expr] = result
            return result

        else
            if @environment[expr.name]
                case @environment[expr.name]
                when NandExpressionVariable
                    return evaluate(@environment[expr.name])
                when NandExpressionSimple
                    return simple_entity(expr)
                when NandExpressionComposite
                    return composite_entity(expr)
                end
            else
                pp @environment
                raise "Unrecognised name: '#{expr.name}'."
            end
        end
    end

    def visit_NandExpressionVariable(expr)
        puts "Variable"
        if @environment[expr.name.lexeme].nil?
            puts "Unrecognised variable '#{expr.name.lexeme}'."
        end
        return evaluate(@environment[expr.name.lexeme])
    end


end