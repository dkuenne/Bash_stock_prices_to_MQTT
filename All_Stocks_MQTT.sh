#!/bin/bash

while IFS=";" read -r Name Kuerzel ISIN
do
  #echo "Name: $Name"
  #echo "Kürzel: $Kuerzel"
  #echo "ISIN: $ISIN"
  #echo ""
  bash ./get_stock_price_lastPriceOnlyToMQTT.sh $ISIN > /dev/null 2>&1 &
done < <(tail -n +2 stocks_list.csv)