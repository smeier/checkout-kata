require 'test/unit'
require_relative 'kata09'

RULES={"A" => {1 => 50, 3 => 130}, "B" => {1 =>30, 2 => 45}, "C" => {1 => 20}, "D" => {1 => 15}, "E" => {1 => 20, 3 => 50, 6 => 200}}

RULES_TABLE="""
 Item   Unit      Special
         Price     Price
 --------------------------
    A     50       3 for 130
    B     30       2 for 45
    C     20
    D     15
    E     20       3 for 50     6 for 200
"""

RULES_FOR_ITEMS_WITH_MORE_THAN_ONE_CHAR = """
ABCDEFG   50       3 for 130
XXXXXXX   20       3 for 50     6 for 200
"""


class TestPrice < Test::Unit::TestCase

  def price(goods)
    co = CheckOut.new(RULES)
    goods.split(//).each { |item| co.scan(item) }
    co.total
  end

  def test_totals
    assert_equal(  0, price(""))
    assert_equal( 50, price("A"))
    assert_equal( 80, price("AB"))
    assert_equal(115, price("CDBA"))

    assert_equal(100, price("AA"))
    assert_equal(130, price("AAA"))
    assert_equal(180, price("AAAA"))
    assert_equal(230, price("AAAAA"))
    assert_equal(260, price("AAAAAA"))

    assert_equal(160, price("AAAB"))
    assert_equal(175, price("AAABB"))
    assert_equal(190, price("AAABBD"))
    assert_equal(190, price("DABABA"))
  end
  
  def test_totals_with_more_than_two_rules_per_item
      assert_equal(200, price("EEEEEE"))
  end

  def test_incremental
    co = CheckOut.new(RULES)
    assert_equal(  0, co.total)
    co.scan("A");  assert_equal( 50, co.total)
    co.scan("B");  assert_equal( 80, co.total)
    co.scan("A");  assert_equal(130, co.total)
    co.scan("A");  assert_equal(160, co.total)
    co.scan("B");  assert_equal(175, co.total)
  end

  def test_incremental_with_multichar_items
    co = CheckOut.from_config_table(RULES_FOR_ITEMS_WITH_MORE_THAN_ONE_CHAR)
    co.scan("ABCDEFG");
    co.scan("ABCDEFG");
    co.scan("ABCDEFG");
    co.scan("XXXXXXX");
    co.scan("XXXXXXX");
    co.scan("XXXXXXX");
    assert_equal(130 + 50, co.total)
  end
end

class TestErrorHandling < Test::Unit::TestCase
    def fail_to_initialize(rules)
        co = CheckOut.new(rules)
        false
    rescue BadRuleError => e
        true
    end

    def test_checkout_cannot_be_initialized_with_broken_configuration
        assert_equal(true, fail_to_initialize({"A" => 1}))
        assert_equal(true, fail_to_initialize({"A" => {"B" => 1}}))
        assert_equal(true, fail_to_initialize({"A" => {"1" => 1}}))
        assert_equal(true, fail_to_initialize({"A" => {1 => "1"}}))
    end

    def test_unknown_items_cant_be_scanned
        co = CheckOut.new(RULES)
        begin
            co.scan("X")
            assert(false)
        rescue UnknownItemError => e
            assert(true)
        end
    end
end

class TestConfigParser < Test::Unit::TestCase
  def test_regex_config_parser
      rules = ConfigParser.new.parse(RULES_TABLE)
      assert_equal(RULES, rules)
  end
end
