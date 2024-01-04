# NFT Sales Analysis Project

## Overview
This project analyzes NFT (Non-Fungible Token) sales data to provide insights into various aspects of the market. The dataset includes information such as NFT names, transaction details, prices in ETH and USD, buyer/seller addresses, and event dates.

## Table of Contents
- [Queries](#queries)
- [Database Schema](#database-schema)
- [Installation](#installation)
- [Usage](#usage)
- [Views](#views)
- [Contributing](#contributing)
- [License](#license)

## Queries

1. **Total Sales Count**
    ```sql
    -- How many sales occurred during this time period?
    SELECT 
        COUNT(*)
    FROM
        pricedata;
    ```
    This query retrieves the total number of sales that occurred during the specified time period.

2. **Top 5 Most Expensive Transactions**
    ```sql
    -- Return the top 5 most expensive transactions (by USD price) for this data set. Return the name, ETH price, and USD price, as well as the date.
    SELECT 
        name, eth_price, usd_price, event_date
    FROM
        pricedata
    ORDER BY usd_price DESC
    LIMIT 5;
    ```
    ...

...

## Database Schema
The dataset is structured with the following columns:

- `transaction_hash`: Unique identifier for each transaction
- `name`: NFT name
- `eth_price`: Price in Ethereum
- `usd_price`: Price in USD
- `event_date`: Date of the transaction
- `buyer_address`: Ethereum address of the buyer
- `seller_address`: Ethereum address of the seller

## Installation
1. Clone the repository.
   ```bash
   git clone https://github.com/anandsullad77/MySQL-project-on-NFT-data.git
