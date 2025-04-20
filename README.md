# Bash stock prices to MQTT

## About

This repo is for getting latest stock prices from Börse Frankfurt and sending it as JSON to an MQTT broker.

It is:
- based on [joqueka/bf4py](https://github.com/joqueka/bf4py) Python package for retrieving the data from boerse-frankfurt.de
- ported by [Claude Sonnet 3.5 from Anthropic](https://www.anthropic.com/) to a bash only version (and modified to only send the current price)
- uses an inofficial API -> may stop working at some point
- far from stable
- takes rather long, about a minute or longer, to retrieve the data (!)

The output can for example be written with Telegraf to an InfluxDB and then be displayed in Grafana (also called "TIG Stack").

---

## Stocks list

The main script looks into `stocks_list.csv` for the ISIN, which then is used for the query.
(For ease of use the list also contains the name and short name of the stock.)
The list consists of the column "Name", "Kuerzel" (short name) and the ISIN.

---

## Usage

You need to modify the `stocks_list.csv` by your own needs, it only contains examples.
Also you need to modify the MQTT string in the `get_stock_price_lastPriceOnlyToMQTT.sh`file to set the correct MQTT broker IP and maybe another MQTT topic.

---

## Notice

Please note that this is just a **quick bodged together** version.
It takes unusual long for getting the stock prices and I wasn't able to check if it also takes that long with the original "bf4py" project.
I didn't put much work in it since the AI ported version worked so far. Except testing it for some weeks and adding some sanity checks (sometimes it did output the value twice separated by a linebreak before the fix) I did not further try to improve this since it's a _nice to have_ project.

---

## License

This project is licensed under CC BY-NC 4.0. To view a copy of this license, visit  https://creativecommons.org/licenses/by-nc/4.0

The "bf4py" project is licensed under MIT License.

Please see the LICENSE file for details.