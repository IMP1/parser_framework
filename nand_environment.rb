class NandEnvironment

    attr_reader :parent
    attr_reader :name

    def initialize(env_name, parent)
        @name = env_name
        @parent = parent
        @mappings = {}
    end

    def [](key)
        return @mappings[key] if @mappings.has_key?(key)
        raise "Unrecognised variable '#{key}'." if @parent.nil?
        return @parent[key]
    end

    def []=(key, value)
        @mappings[key] = value
    end

    def has?(key)
        return true if @mappings.has_key?(key)
        return false if @parent.nil?
        return @parent.has?(key)
    end

end