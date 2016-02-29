require 'rubygems'
require 'sinatra/base'
require 'mongo'
require 'json'

class CalPoly < Sinatra::Base
  ##
  # This is the config block where you can enable MongoDB
  # If you want to use MongoDB for your data (instead of the JSON files),
  # uncomment this block and change the config settings accordingly
  #
  # configure do
  #   db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'calpoly')
  #   set :mongo_db, db[:courses]
  #   # I18n.enforce_available_locales = false
  # end

  # This is just the boring home page
  get '/' do
    erb :index
  end

  # API endpoint for getting all the classes from a dept (i.e. each JSON file)
  # Do some basic sanitizing on the dept param
  get '/departments/:dept' do
    dept = params['dept'].upcase.gsub(/\W/, '')
    file = File.join(File.dirname(__FILE__), "data", "#{dept}.json")
    content_type :json
    send_file file
  end

end
