#!/bin/bash
HERE=$(pwd)
export PATH="$HERE/bin:$PATH"
export DYLD_LIBRARY_PATH="$HERE/lib:$DYLD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$HERE/bin:$HERE/lib:$HERE/openssl/lib:$LD_LIBRARY_PATH"
export RUBYLIB="$HERE/lib/ruby/site_ruby/3.2.0:$HERE/lib/ruby/site_ruby/3.2.0/arm64-darwin23:$HERE/lib/ruby/site_ruby:$HERE/lib/ruby/vendor_ruby/3.2.0:$HERE/lib/ruby/vendor_ruby/3.2.0/arm64-darwin23:$HERE/lib/ruby/vendor_ruby:$HERE/lib/ruby/3.2.0:$HERE/lib/ruby/3.2.0/arm64-darwin23"
export RUBYOPT="--encoding utf-8:utf-8 -rclean_load_path"

