#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# fetch_last_price_ticker.sh
# Simple shell script - used in two places - to
# pull the ticker symbol for the last price we fetched.

FILENAME=~/.prices
if [ -f "${FILENAME}" ]
then
  head "${FILENAME}" | cut -d '|' -f 1
fi