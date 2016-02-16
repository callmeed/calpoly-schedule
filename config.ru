# Run locally with rackup -p 4567
require 'rubygems'
require 'sinatra'

Bundler.require

require File.join(File.dirname(__FILE__), 'app.rb')
run CalPoly
