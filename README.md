# Groups of assets
The groups of assets include:
<ol> Group 1 – two assets (1 min frequency, traded during NYSE sessions - on working days between 9:30 and 16:00 CET): </ol>
<li> SP – futures contract for S&P 500 index (transaction cost = 10$, point value = 50$). </li>
<li> NQ – futures contract for NASDAQ index (transaction cost = 10$, point value = 20$). </li>
<ol> Group 2 – four assets (5 min frequency, traded almost 24 hours a day with 1 hour break betweem 17:00 and 18:00 CET - quotations start on Sundays at 18:00 and last until 17:00 on Friday): </ol>
<li> CAD – futures contract for Canadian dollar (transaction cost = 5$, point value = 100000$). </li>
<li> AUD – futures contract for Australian dollar (transaction cost = 5$, point value = 100000$). </li>
<li> XAU – futures contract for gold (transaction cost = 10$, point value = 100$). </li>
<li> XAG – futures contract for silver (transaction cost = 5$, point value = 5000$). </li>
CAUTION: There are separate data files for group 1 and group 2 for each quarter.

# Any combinations within groups allowed
Within each of the above groups of assets you can:
trade just a single asset, or
put (selected) assets together in pair(s) as spreads, or
trade each of selected assets separately and treat them as a portfolio (applying the same or different strategy for each asset).
If trading more than one asset (spread), remember to include positive transaction costs for each of them.

# Trading sizes
Assume trading just with one unit of any security/spread, so the only positions available are:
flat / neutral (0),
short (-1),
long (+1).

# Different approaches, entry/exit techniques
For each of the (groups of) assets please consider and compare at least 2 different types of entry techniques (approaches), each with several combinations of parameters (memories of moving statistics, multipliers, etc.).
As different approaches one may treat (each for the trend following or mean reverting strategy) for example an entry/exit technique based on:
a single moving average/moving median/moving quantile,
two or more intersecting moving averages/moving medians/moving quantiles,
a single moving average/moving median/moving quantile and a selected volatility measure (breakout models),
any other that comes to your mind.

# Additional filtering
Additional filtering may be added (eg. in pair trading strategies):
based on correlation between two (or more) assets,
based on regression between two (or more) assets,
based on testing for cointegration between two (or more) assets,
based on testing for Granger causality between two (or more) assets,
any other that comes to your mind.

# Common assumptions
Common assumptions for group 1:
do not use in calculations the data from the first and last 10 minutes of the session (9:31-9:40 and 15:51-16:00) – put missing values there,
do not hold positions overnight (exit all positions 15 minutes before the session end, i.e. at 15:45),
do not trade within the first 20 minutes of stocks quotations (9:31-9:50), but DO use the data for 9:41-10:00 in calculations of signal, volatility, etc.
Common assumptions for group 2:
do not hold positions during the breaks (exit all positions 15 minutes before the break starts, i.e. at 16:45),
do not trade within the first 15 minutes after the break (until 18:15).
One may make additional assumptions, however they should be clearly explained and justified, e.g. stop-loss condition, etc.

# Selection of best strategy
CAUTION !!!!! As mentioned before, the data are divided in two parts – in-sample quarters and out-of-sample quarters. At first teams are provided just with the in-sample data to do a research and select the best strategy for each group of assets separately.
Exactly the same strategy (the same entry/exit technique and parameters) has to be applied for a particular group of assets in each quarter.
For example if after research you find that for a particular asset the best strategy is a trend following strategy based on the cross-over of two exponential moving averages – EMA60 and EMA10 – you should apply this particular strategy with the same parameters and all other assumptions to every quarter of your data (first in-sample, then out-of-sample once available) and report the results.
The best/optimal strategy may be different for different assets, but again – it has to be consistently applied on all quarters of data.
Selecting different best strategies (or just different parameters) for the same asset in different quarters of the data is not allowed.

# Performance measures
For the selected best strategy for each group of assets aggregate the strategy P&Ls to daily and based on daily results calculate the following measures (separately for each quarter):
gross SR – Sharpe ratio based on gross daily P&L (without transaction costs, denoted in monetary terms),
net SR – Sharpe ratio based on net daily P&L (with transaction costs included, denoted in monetary terms),
gross cumP&L – cumulative profit and loss at the end of the investment period (last value of the cumP&L series) without transaction costs, denoted in monetary terms,
net cumP&L – cumulative profit and loss at the end of the investment period (last value of the cumP&L series) with transaction costs included, denoted in monetary terms,
av.ntrades – average daily number of trades.
and report them in a table at the end of the presentation and report.
Based on the above mentioned measures the final summary statistic will be calculated for each quarter separately. The formula for the summary statistic is the following:
stat=(netSR−0.5)∗max(0,log(abs(
net.PnL
1000

)))
stat=(netSR−0.5)∗max(0,log(abs(net.PnL1000)))
This promotes strategies which give relatively high net Sharpe ratios (above 0.5) and higher net pnl.
Please add this statistic to the summary table and in addition use codes that will save this table as a csv file.
In the end the sum of the above mentioned summary statistic over all quarters (in-sample and out-of-sample) will be used to rank the teams, divide them in quartile groups and give points for strategy performance.
