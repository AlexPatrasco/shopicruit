# Shopicruit Revenue calculator
This is the implementation of a revenue calculator for the shopicruit task summer 2017.

## Commentaries

Since the orders yielded by Shopify may have multiple currencies, besides ```revenue_usd``` method, which returns total revenue in dollars, there is also a ```revenue_by_currency``` method. The latter returns a hash of type ```{:currency => {:total_price => price, :total_tax => tax}}```

## Results
Running first ```revenue_by_currency``` we see that all of the orders are in CAD and the tax is 0

```
CAD
  Subtotal: 15449.72
  Tax: 0.0
  Total: 15449.72
```

Later, by running revenue_usd, we obtain a result in dollars.

```
Total revenue is 11594.71$
```
