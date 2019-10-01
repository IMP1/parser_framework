
module SchwahType

    class BaseType
    end

    class Type < BaseType
    end

    class Boolean < BaseType
    end

    class Numeric < BaseType
    end

        class Integer < Numeric
        end

        class Rational < Numeric
        end

        class Decimal < Numeric
        end

        class Unit < Numeric
        end

    class String < BaseType
    end

    class Collection < BaseType
    end

    class Array < Collection
    end

    class List < Collection
    end

    class Set < Collection
    end

    class Function < BaseType
    end

    class Procedure < BaseType
    end

    class Union < BaseType
        def initialize(*subtypes)
        end
    end

    class Struct < BaseType
    end

end
