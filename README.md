## About the project
This is an implementation of the Kata [Back to the Checkout](http://codekata.com/kata/kata09-back-to-the-checkout/).
The Checkout class calculates the total price of a number of items. In a normal supermarket, things are identified using Stock Keeping Units, or SKUs. In the following examples we’ll use individual letters of the alphabet (A, B, C, and so on) to keep them short, but of course identifiers of arbitrary length can be used in practice.
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

## Design decisions and limitations
The main functionality is devided into four parts each implemented in a separate class:
- Parsing the configuration
- Checking the configuration
- Scanning the items
- Calculating the total

The main class "CheckOut" just combines these classes to provide the interface required by the kata.
Thus each of the parts could easily be replaced by a different implementation.

### Limitations
- Right now errors have to be handled by the client. E.g. if an item is unknown to the scanner it just throws an error. The only way for the client to get the price for this item into the total is by somehow adding it to the result after the fact. A better way to solve this might be to offer the possibility to register a callback, that gets called for items that are unknown and returns the actual price of the item. But since it's not clear right now whether any client would use this functionality, we're keeping the code base simple and get version 0.1 out the door to get some feedback. 
- Replacing parts of the functionality right now requires code changes. It might be desirable to be able to configure e.g. the PriceCalculator at runtime, but since we're not sure we're gonna need it (we probably ain't), this is not implemented for now.

