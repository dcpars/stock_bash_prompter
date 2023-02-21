import ssl

from bs4 import BeautifulSoup, ParserRejectedMarkup
import os
import random
import re
import requests
from requests import RequestException
from urllib3.exceptions import MaxRetryError

DEBUG_MODE = False
DEFAULT_TICKER = "UBER"
TICKER_REGEX = "^[A-Z]{1,5}$"


def fetch_ticker_symbol():
    try:
        ticker = os.environ['ticker_symbol']
        if ticker is None or len(ticker) < 1:
            return DEFAULT_TICKER
        formatted_ticker = ticker.strip().upper()
        if re.match(TICKER_REGEX, formatted_ticker):
            return formatted_ticker
    except KeyError:
        return DEFAULT_TICKER


def parse_current_price(parser):
    attrs = {"id": "quote-header-info"}
    container_div = parser.find("div", attrs)
    # The div tag containing the price is the last child
    price_container_div = None
    for child in container_div.children:
        price_container_div = child
    # The price is nested a few elements in
    price_div = price_container_div.div.div
    fin_streamer = next(price_div.children)
    return float(fin_streamer.text)


def parse_previous_close(parser):
    attrs = {"id": "quote-summary"}
    container_div = parser.find("div", attrs)
    table_row = container_div.div.table.tbody.tr
    table_cell = next(table_row.children).next_sibling
    return float(table_cell.text)


def parse_prices(html):
    try:
        parser = BeautifulSoup(html, 'html.parser')
        return {"current_price": parse_current_price(parser),
                "previous_close": parse_previous_close(parser)}
    except ParserRejectedMarkup:
        return None


def fetch_html(ticker_symbol):
    try:
        url = "https://finance.yahoo.com/quote/{tc}/".format(tc=ticker_symbol)
        response = requests.get(url=url)
        if response.ok:
            return response.content.decode()
    except (RequestException, MaxRetryError, ssl.SSLCertVerificationError):
        return None


def fetch_prices(ticker_symbol):
    if not DEBUG_MODE:
        html = fetch_html(ticker_symbol)
        return parse_prices(html) if html is not None else None
    else:
        # Support random price generation for testing, so we don't
        # spam Yahoo finance and get blocked.
        previous_close = 35.00
        change = round(random.uniform(-2.00, 2.00), 2)
        return {"current_price": previous_close + change, "previous_close": previous_close}


def calculate_percent_change(prices):
    current_price = prices["current_price"]
    previous_close = prices["previous_close"]
    change_amount = abs(current_price - previous_close)
    percent_change = (change_amount / previous_close) * 100
    if current_price < previous_close:
        percent_change *= -1
    return round(percent_change, 2)


def calculate_percent_change_color(percent_change):
    if percent_change > 0:
        return "\033[0;32m"  # Green
    else:
        return "\033[0;31m"  # Red


def format_percent_change(percent_change):
    if percent_change > 0:
        return "+{pc}".format(pc=percent_change)
    else:
        return str(percent_change)


if __name__ == '__main__':
    ticker_symbol = fetch_ticker_symbol()
    prices = fetch_prices(ticker_symbol)
    if prices is not None:
        percent_change = calculate_percent_change(prices)
        color = calculate_percent_change_color(percent_change)
        formatted_change = format_percent_change(percent_change)
        print("{ts}|${cp}|{pc}%|{c}".format(ts=ticker_symbol,
                                            cp=prices["current_price"],
                                            pc=formatted_change,
                                            c=color))
