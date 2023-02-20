#!/bin/bash

# update_stock_price.sh

# Ensure we're in the right directory so we can reference
# adjacent script(s).
directory=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
pushd "${directory}" >/dev/null 2>&1 || exit

# Docker cleanup
cleanup_docker() {
    local container_id=$(docker container ls -a | grep bash_prompter | cut -d ' ' -f 1)
    if [ -n "${container_id}" ]
    then
        docker stop "${container_id}" >/dev/null 2>&1
        docker rm -f "${container_id}" >/dev/null 2>&1
    fi
}

# Set ticket symbol. It's possible the user has requested a different
# ticket, which explains some of the clunkiness. 
# Could use default variable setting here (i.e. ${TICKER_SYMBOL:=UBER}) 
# but I also want to export at the same time. 
set_ticker_symbol() {
    if [ -z "${TICKER_SYMBOL:-}" ]  # No env variable set.
    then
        if [ -f  ~/.new_ticker ]    # User has changed the ticker recently
        then
            local new_ticker=$(cat ~/.new_ticker)
            export TICKER_SYMBOL="${new_ticker}"
            rm -f ~/.new_ticker
        else
            # We have previously fetched a price for a ticker symbol.
            last_ticker_symbol=$(./fetch_last_price_ticker.sh)
            if [ -z "${last_ticker_symbol}" ]
            then
              export TICKER_SYMBOL="UBER"   # No ticker symbol is set anywhere, default.
            else
              export TICKER_SYMBOL="${last_ticker_symbol}"
            fi
        fi
    fi
}

cleanup_docker
set_ticker_symbol
docker build -t bash_prompter --build-arg ticker="${TICKER_SYMBOL}" . >/dev/null 2>&1
docker run -e ticker_symbol="${TICKER_SYMBOL}" bash_prompter > ~/.prices
popd >/dev/null 2>&1 || exit