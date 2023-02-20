#!/bin/bash

# set_prompt.sh
# This is not meant to be executed standalone, but rather sourced
# from another script (ideally ~.bash_profile or ~.bashrc).

update_new_ticker_symbol() {
    last_ticker_symbol=$(./fetch_last_price_ticker.sh)    # The last symbol we fetched a price for
    if [ "${TICKER_SYMBOL}" != "${last_ticker_symbol}" ]
    then
        if [ -n "${TICKER_SYMBOL}" ]                      # Avoid writing an empty variable to a file
        then
          echo "${TICKER_SYMBOL}" > ~/.new_ticker
        fi
    fi
}

process_prices() {
    prices=$1
    if [ -n "${prices}" ]
    then
        ticker_symbol=$(echo "${prices}" | cut -d '|' -f 1)
        current_price=$(echo "${prices}" | cut -d '|' -f 2)
        percent_change=$(echo "${prices}" | cut -d '|' -f 3)
        color=$(echo "${prices}" | cut -d '|' -f 4)
        export CURRENT_PRICE="${current_price}"
        export PERCENT_CHANGE="${percent_change}"
        export PERCENT_CHANGE_COLOR="${color}"
        export PS1="[\w] [${ticker_symbol}: \${CURRENT_PRICE} (${PERCENT_CHANGE_COLOR}\${PERCENT_CHANGE}\033[0m)] "
    fi
}

prices=$(cat ~/.prices)

# If the user has changed the ticker symbol, track that so the 
# next job can pick it up. 
update_new_ticker_symbol

# Update the bash prompt with pricing.
process_prices "${prices}"