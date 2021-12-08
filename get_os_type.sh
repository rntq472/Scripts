#! /usr/bin/sh
lsb_release -ir | cut -f2 | paste -s -d_
