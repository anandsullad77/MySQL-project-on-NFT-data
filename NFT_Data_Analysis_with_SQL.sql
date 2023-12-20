
-- 1.0 How many sales occurred during this time period? 
SELECT 
    COUNT(*)
FROM
    pricedata;
    
-- 2.0 Return the top 5 most expensive transactions (by USD price) for this data set. Return the name, ETH price, and USD price, as well as the date.
SELECT 
    name, eth_price, usd_price, event_date
FROM
    pricedata
ORDER BY usd_price DESC
LIMIT 5;


-- 3.0 Return a table with a row for each transaction with an event column, a USD price column, and a moving average of USD price that averages the last 50 transactions.
SELECT 
    transaction_hash, 
    usd_price, 
    AVG(usd_price) OVER(ORDER BY event_date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) as usd_mv_avg
FROM
    pricedata;

--  4.0 Return all the NFT names and their average sale price in USD. Sort descending. Name the average column as average_price.
SELECT 
    name, AVG(usd_price) as average_price
FROM
    pricedata
GROUP BY name
ORDER BY name;

-- 5.0 Return each day of the week and the number of sales that occurred on that day of the week, as well as the average price in ETH. Order by the count of transactions in ascending order.
SELECT 
    DAYOFWEEK(event_date), COUNT(*), AVG(eth_price)
FROM
    pricedata
GROUP BY DAYOFWEEK(event_date)
ORDER BY COUNT(*);

-- 6.0  Construct a column that describes each sale and is called summary. The sentence should include who sold the NFT name, who bought the NFT, 
-- who sold the NFT, the date, and what price it was sold for in USD rounded to the nearest thousandth.
 -- Here’s an example summary:
 -- “CryptoPunk #1139 was sold for $194000 to 0x91338ccfb8c0adb7756034a82008531d7713009d from 0x1593110441ab4c5f2c133f21b0743b2b43e297cb on 2022-01-14”

SELECT 
    (CONCAT(name,
            ' was sold for $',
            ROUND(usd_price, - 3),
            ' to ',
            seller_address,
            ' from ',
            buyer_address,
            ' on ',
            event_date)) as summary
FROM
    pricedata;

-- 7.0 Create a view called “1919_purchases” and contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.
CREATE VIEW 1919_purchases AS
    SELECT 
        *
    FROM
        pricedata
    WHERE
        buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';


-- 8.0 Create a histogram of ETH price ranges. Round to the nearest hundred value. 
SELECT 
    ROUND(eth_price, - 2) AS bucket,
    COUNT(*) AS count,
    RPAD('', COUNT(*), '*') AS bar
FROM
    pricedata
GROUP BY bucket
ORDER BY bucket;

-- 9.0 Return a unioned query that contains the highest price each NFT was bought for and a new column called status saying “highest” with 
-- a query that has the lowest price each NFT was bought for and the status column saying “lowest”. The table should have a name column, 
-- a price column called price, and a status column. Order the result set by the name of the NFT, and the status, in ascending order. 
SELECT 
    name, MAX(eth_price) AS price, CONCAT('Highest') AS status
FROM
    pricedata
GROUP BY name 
UNION SELECT 
    name, MIN(eth_price) AS price, CONCAT('Lowest') AS status
FROM
    pricedata
GROUP BY name
ORDER BY name;

-- 10. What NFT sold the most each month / year combination? Also, what was the name and the price in USD? Order in chronological format. I have consider the all top NFTs with same number of sale_counts
SELECT 
    name,
    usd_price,
    sale_year,
    sale_month,
    sale_count,
    ranked_in_month
FROM (
    SELECT 
        name,
        MAX(usd_price) as usd_price,
        YEAR(event_date) AS sale_year,
        MONTH(event_date) AS sale_month,
        COUNT(*) AS sale_count,
        DENSE_RANK() OVER (PARTITION BY YEAR(event_date), MONTH(event_date) ORDER BY COUNT(*) DESC) as ranked_in_month
    FROM
        pricedata
    GROUP BY name, YEAR(event_date), MONTH(event_date)
) as dt
WHERE ranked_in_month = 1;

-- 11.0 Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year).
SELECT 
    YEAR(event_date) AS sale_year,
    MONTH(event_date) AS sale_month,
    COUNT(*) AS sum_of_sales_volume
FROM
    pricedata
GROUP BY sale_year , sale_month
order by sale_year , sale_month; 


-- 12.0 Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.
SELECT 
    COUNT(*)
FROM
    pricedata
WHERE
    buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685'
        OR seller_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';
        

-- 13.0 Create an “estimated average value calculator” that has a representative price of the collection every day based off of these criteria:
--  - Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
--  - Take the daily average of remaining transactions
--  a) First create a query that will be used as a subquery. Select the event date, the USD price, and the average USD price for each day using a window function. Save it as a temporary table.
--  b) Use the table you created in Part A to filter out rows where the USD prices is below 10% of the daily average and return a new estimated value
--  which is just the daily average of the filtered data
CREATE TEMPORARY TABLE avg_usd_price_per_day as
SELECT 
    event_date, usd_price, AVG(usd_price)over(partition by date(event_date)) as daily_avg
FROM
    pricedata;

SELECT 
    * , AVG(usd_price)over(partition by date(event_date)) as new_estimated_value
FROM
    avg_usd_price_per_day
WHERE
    usd_price > (0.9 * daily_avg);
    
    
-- 14.0 Give a complete list ordered by wallet profitability (whether people have made or lost money)
-- In the below solution the current money which are in form of NFT as are not conisder to calculate profit or loss as we dont know the exact price of that NFT right now.-- 
SELECT 
    walletID, SUM(cost_of_trade) as profitability      	-- adding spent money and moeny got from the trades, we get total profit or loss in total 
FROM
    (SELECT 
        buyer_address AS walletID, (usd_price * - 1) AS cost_of_trade	-- As buyer is spending the money I have multiplied it by -1 to indicate that its the money taken out from wallet 
    FROM
        pricedata UNION SELECT 
        seller_address AS walletID, (usd_price * 1) AS cost_of_trade 	-- As buyer is getting the money I have multiplied it by +1 to indicate that its the money is added to wallet 
    FROM
        pricedata) AS total_transactions
GROUP BY walletID
ORDER BY SUM(cost_of_trade);
