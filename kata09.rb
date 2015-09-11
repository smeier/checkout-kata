class CheckOut
    def initialize(rules)
        @rules = rules
        @total = 0
    end

    def scan(item)
        @total += @rules[item]
    end

    def total
        @total
    end
end
