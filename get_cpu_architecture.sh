#! /usr/bin/sh
lscpu | grep "Architecture" | tr -s ' ' | cut -d' ' -f2
