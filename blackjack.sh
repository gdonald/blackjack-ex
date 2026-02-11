#!/bin/sh

# Save current terminal settings
STTY_SAVE=$(stty -g)

# Restore terminal settings on exit (even if interrupted)
trap 'stty "$STTY_SAVE"; echo' EXIT INT TERM

# Set terminal to raw mode for single-character input
stty raw -echo

# Run the blackjack escript
./blackjack "$@"
