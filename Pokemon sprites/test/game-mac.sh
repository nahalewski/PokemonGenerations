#!/bin/bash
cd "/Users/bennahalewski/Desktop/PokemonStudio/Pokemon Studio.app/Contents/Resources/psdk-binaries/ruby-dist"
source ./setup.sh
cd "/Users/bennahalewski/Documents/test/test"
PSDK_BINARY_PATH="/Users/bennahalewski/Desktop/PokemonStudio/Pokemon Studio.app/Contents/Resources/psdk-binaries/" ruby Game.rb "$@"
