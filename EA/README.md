### MQL5 EA Template

The EA source code and ex5 contain a rough template for Expert Advisor development. A simple trading strategy, buying a price crossover with a moving average, is used as an example, but much more logic could be added. 

Stops and take profits can be turned off or on, along with price in points (pip * 10) amounts. 

The trade randomizer sets a random time to make a trade upon signal green light, at 1/6 of the current timeframe, so for an H1 bar this would be Minutes 0 - 9. By doing this we are not always trading with everyone else at the open of the new candle. 

The weekend paper trader, when turned on, makes paper trades in the background, and only approves live trading when a profitable paper trade has been made-resetting at the beginning of each week. 
