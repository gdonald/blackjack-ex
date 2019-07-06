#!/bin/sh
stty -f /dev/tty icanon raw
./blackjack
stty echo echok icanon -raw
