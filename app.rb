require 'rubygems'
require 'sinatra/base'
require 'mongo'
require 'json'

class CalPoly < Sinatra::Base
  configure do
    db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'calpoly')
    set :mongo_db, db[:courses]
    # I18n.enforce_available_locales = false
  end

  get '/' do
    @products = settings.mongo_db.find({ price: { "$lt" => 10000 } }).sort(timestamp: -1).limit(25)
    erb :index, layout: :layout
  end

  get '/engineering' do
    @courses = settings.mongo_db.find({ college_name: "Engineering" }).sort({course_name: 1})
    content_type :json
    @courses.to_a.to_json
  end
end
