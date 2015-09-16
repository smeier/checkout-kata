# Checkout provides methods to scan multiple items and in the end calculate
# the total afterwards (or in between for that matter)
class CheckOut
    def self.from_config_table(table)
        self.new(ConfigParser.new.parse(table))
    end

    def initialize(rules)
        RuleChecker.new.check_rules(rules)
        @price_calculator = PriceCalculator.new rules
        @scanner = Scanner.new(rules.keys)
    end

    def total()
        @price_calculator.total(@scanner.scanned_items)
    end

    def scan(item)
        @scanner.scan(item)
    end
end


# The Scanner is responsible for collecting the items being scanned
class Scanner
    attr_reader :scanned_items

    def initialize(item_list)
        @item_list = item_list
        @scanned_items = {}
    end

    # adds the item to to the list of scanned items if it is include in
    # item_list. Otherwise an UnknownItemError is thrown,
    def scan(item)
        unless @item_list.include?(item)
            raise UnknownItemError.new
        end
        if @scanned_items[item]
            @scanned_items[item] += 1
        else
            @scanned_items[item] = 1
        end
    end

end

class UnknownItemError < StandardError
end

class BadRuleError < StandardError
    def initialize(root_cause)
        @root_cause = root_cause
    end
end

# Calculates the price of a list of items according to the
# rules given to the constructor
class PriceCalculator
    def initialize(rules)
        @rules = rules
    end

    def total(items)
        return items.map{|item, count| item_total(item, count)}.inject(0, :+)
    end
    
    def item_total(item, count)
        total = 0
        items_left = count
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


class ConfigParser
    LINE_REGEX = /(\S+)\s+(\d+)\s+(.*)/
    DISCOUNT_REGEX = /\S+\s+for\s+\d+\s*/

    def parse(str)
        valid_rules = str.each_line.select{|line| is_valid_rule(line)}
        Hash[valid_rules.map{|line| rules_for_one_item(line)}]
    end

    def is_valid_rule(line)
        line.match(LINE_REGEX)
    end
    
    def rules_for_one_item(line)
        rule_parts = line.match(LINE_REGEX).captures
        item = rule_parts.shift
        price_for_one = rule_parts.shift.to_i
        discounts = rule_parts.shift.scan(DISCOUNT_REGEX).flatten
        rules = Hash[discounts.map{|discount| parse_discount(discount)}]
        rules[1] = price_for_one
        [item, rules]
    end

    def parse_discount(discount)
        count, price = discount.match(/(\S+)\s+for\s+(\S+)/).captures
        [count.to_i, price.to_i]
    end
end


# Checks that rules match the format expected
# raises an exception otherwise
class RuleChecker
    def check_rules(rules)
        rules.keys.each do |item|
            check_rules_for_item(rules[item])
        end
    rescue StandardError => e
        raise BadRuleError.new(e)
    end

    def check_rules_for_item(rules)
        rules.keys.each do |count|
            check_is_int(count)
            check_is_int(rules[count])
        end
    end

    def check_is_int(o)
        x = 0 + o
    end
end
