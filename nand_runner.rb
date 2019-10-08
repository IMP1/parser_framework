require_relative 'visitor'

class NandRunner < Visitor

    TICK_DELAY = 1

    def initialize(statements)
        @statements = statements
        @environment = {}

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
                end
                $stdout.flush
                sleep(TICK_DELAY)
                @current_tick += 1
            rescue SignalException => e
                break
            end
        end
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
        pp @environment
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
                return evaluate(@environment[expr.name]) # TODO: map parameters/arguments across
            else
                pp @environment
                raise "Unrecognised name: '#{expr.name}'."
            end
        end
    end

    def visit_NandExpressionVariable(expr)
        puts "Variable"
        p expr
    end


end