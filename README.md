```
 ______     ______   ______     ______     __  __    
/\  ___\   /\__  _\ /\  __ \   /\  ___\   /\ \/ /    
\ \___  \  \/_/\ \/ \ \ \/\ \  \ \ \____  \ \  _"-.  
 \/\_____\    \ \_\  \ \_____\  \ \_____\  \ \_\ \_\ 
  \/_____/     \/_/   \/_____/   \/_____/   \/_/\/_/ 
                                                     
 ______   ______     ______     __    __     ______   ______   ______     ______    
/\  == \ /\  == \   /\  __ \   /\ "-./  \   /\  == \ /\__  _\ /\  ___\   /\  == \   
\ \  _-/ \ \  __<   \ \ \/\ \  \ \ \-./\ \  \ \  _-/ \/_/\ \/ \ \  __\   \ \  __<   
 \ \_\    \ \_\ \_\  \ \_____\  \ \_\ \ \_\  \ \_\      \ \_\  \ \_____\  \ \_\ \_\ 
  \/_/     \/_/ /_/   \/_____/   \/_/  \/_/   \/_/       \/_/   \/_____/   \/_/ /_/
```

## How to Install

1. Clone the repository

2. Add the job to your crontab
```bash
# Make sure $PATH is available in this crontab if it isn't already. 
# PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Runs only when the market is open. For more frequent updates, adjust
# the leftmost (minute) value. 
# Make sure the path to the script matches the location on your machine
*/10 09-16 * * 1-5 ~/Code/stock_bash_prompter/update_stock_price.sh
```
3. Add to your .bashrc or .bash_profile
```bash
update_prompt() {
  # Replace the directory below with the directory on your machine 
  pushd /Users/danparsons-drizly/Code/stock_bash_prompter/ >/dev/null 2>&1
  source set_prompt.sh
  popd >/dev/null 2>&1
}

trap update_prompt DEBUG
PROMPT_COMMAND=update_prompt
```

## Usage

```bash
# By default, this will fetch pricing for UBER. So with this job activated, your bash 
# prompt will update periodically with UBER's price.

[~/Code/stock_bash_prompter] [UBER: $34.77 (-4.0%)]

# To switch the ticker symbol, set the TICKER_SYMBOL variable to whatever you'd like. 
# This will not instantly change the prompt, but as soon as prices are next fetched,
# the prompt will update with this new symbol and pricing.

export TICKER_SYMBOL=GOOG
# ...10 minutes later
[~/Code/stock_bash_prompter] [GOOG: $94.59 (-1.24%)]

# If you're impatient and want to see new pricing immediately, simply run the 
# script to fetch new pricing. 

./update_stock_price.sh
```
