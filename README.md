# Cal Poly Schedule Data

This is a little project that scrapes the data found at:

http://schedules.calpoly.edu/

and turns it into JSON data and a simple web API. A small Sinatra app handles the
web rendering.

There is also the option of storing to (and fetching from) MongoDB.

This was built as part of a talk I'm giving on app development and talking to web
APIs.

## API demo

You can view the API online here:

https://cp-schedule-api.herokuapp.com/

(it is a Sinatra app on Heroku)

## If you just want the data

All the data is found in the `/data` dir. There is a separate JSON file for each
department prefix (i.e. CPE.json has all CPE courses).

Right now I just have data for Spring quarter 2016.
