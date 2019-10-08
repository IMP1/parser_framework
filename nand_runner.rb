require_relative 'visitor'

class NandRunner < Visitor

    TICK_DELAY = 1

    def initialize(statements)
        @statements = statements
        @environment = {}

        @variables = {}
        @current_tick = 0
        @last_update = {}
        @last_value = {}
        @queues = {}
    end

    def run
        return if @statements.empty?
        loop do
            begin
                @statements.each do |stmt|
                    execute(stmt)
                    @current_tick += 1
                end
                $stdout.flush
                sleep(TICK_DELAY)
                break # TODO: remove to continue loop
            rescue SignalException => e
                break
            end
        end
    end

    def simple_entity(expr)
        puts "Simple Entity"
        p expr.params
        p @environment[expr.name].params
        raise "Wrong number of arguments" if expr.params.size != @environment[expr.name].params.size
        args = expr.params.map { |arg| evaluate(arg) }
        old_variables = {}
        @environment[expr.name].params.each_with_index do |param, i|
            old_variables[param.name.lexeme] = @variables[param.name.lexeme]
            @variables[param.name.lexeme] = args[i]
        end
        puts "#{expr.name} => #{@environment[expr.name].name}"
        result = evaluate(@environment[expr.name]) # TODO: map parameters/arguments across
        old_variables.each do |key, value|
            if value.nil?
                @variables.delete(key)
            else
                @variables[key] = value
            end
        end
        return result
    end

    def composite_entity(expr)
        puts "Composite Entity"
        composite = @environment[expr.name]
        args = expr.params
        params = composite.params
        p args
        p params
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

    def visit_NandStatementOutput(stmt)
        puts evaluate(stmt.value) ? 1 : 0
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
        puts "#{expr.name.lexeme} => #{@variables[expr.name.lexeme]}"
        return @variables[expr.name.lexeme]
    end


end