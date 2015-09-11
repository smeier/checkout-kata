class CheckOut
    def initialize(rules)
        @rules = rules
        @items = {}
    end

    def scan(item)
        if @items[item]
            @items[item] += 1
        else
            @items[item] = 1
        end
    end

    def total
        return @items.map{|item, count| item_total(item, count)}.inject(0, :+)
    end
    
    def item_total(item, count)
        total = 0
        items_left = @items[item]
        while items_left > 0
            items_used, cost = take_as_much_items_as_possible(@rules[item], items_left)
            total += cost
            items_left -= items_used
        end
        total
    end

    def take_as_much_items_as_possible(rules, items_left)
        candidate_rules = rules.select{|count, price| count <= items_left}
        best_rule = candidate_rules.max_by{|count, price| count}
        best_rule.to_a
    end
end
