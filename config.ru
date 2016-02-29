# Run locally with rackup -p 4000
# OR
# use rerun gem if you want to edit and not have to restart every time
# rerun -- rackup --port 4000 config.ru

require 'rubygems'
require 'sinatra'

Bundler.require

require File.join(File.dirname(__FILE__), 'app.rb')
run CalPoly
