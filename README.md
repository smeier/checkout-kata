## About the project
This is an implementation of the Kata [Back to the Checkout](http://codekata.com/kata/kata09-back-to-the-checkout/).
The Checkout class calculates the total price of a number of items. In a normal supermarket, things are identified using Stock Keeping Units, or SKUs. In the following examples we’ll use individual letters of the alphabet (A, B, C, and so on) to keep them short. 
Our goods are priced individually. In addition, some items are multipriced: buy n of them, and they’ll cost you y cents. For example, item ‘A’ might cost 50 cents individually, but this week we have a special offer: buy three ‘A’s and they’ll cost you $1.30. 
For example this week's prices might be:

    Item   Unit      Special
             Price     Prices
    ---------------------------------------
       A     50       3 for 130
       B     30       2 for 45
       C     20
       D     15
       E     20       3 for 50     6 for 200

Our checkout accepts items in any order, so that if we scan a B, an A, and another B, we’ll recognize the two B’s and price them at 45 (for a total price so far of 95). Because the pricing changes frequently, we need to be able to pass in a set of pricing rules each time we start handling a checkout transaction.

The interface to the checkout looks like:

    co = CheckOut.new(pricing_rules)
    co.scan(item)
    co.scan(item)
        :    :
    price = co.total


The argument to the CheckOut constructor ist a hash of hashes but there's a more convenient way to provide the rules using the format from the example above:


    co = CheckOut.from_config_table ("""
     Item   Unit      Special
             Price     Price
     --------------------------
        A     50       3 for 130
        B     30       2 for 45
        C     20
        D     15
        E     20       3 for 50     6 for 200
    """

## Error handling
- Upon construction CheckOut makes sure that the rules provided match the expected format. Otherwise an BadRuleError is thrown.
- Only items that are present in the rules specified can be scanned successfully. If the item to be scanned is unknown, an UnknownItemEerror is thrown.

