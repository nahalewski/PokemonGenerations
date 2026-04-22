#!/bin/bash
cd ruby-dist
source setup.sh
cd ..
ruby Game.rb "$@"
