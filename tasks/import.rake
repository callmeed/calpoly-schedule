require 'open-uri'
require 'rubygems'
require 'openssl'
require 'nokogiri'
require 'mongo'

MONGO_DB_NAME = 'calpoly'
MONGO_COLLECTION_NAME = :courses

namespace :db do
  desc 'Remove all course records from the DB'
  task :remove_all do
    db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => MONGO_DB_NAME)
    result = db[MONGO_COLLECTION_NAME].delete_many
    puts "#{result.n} records have been removed"
  end
end

namespace :import do
  desc 'Import courses from schedules.calpoly.edu'
  task :courses do

    # Mongo connection
    db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => MONGO_DB_NAME)

    # These are all the different college schedule URLs
    urls = [ { college_name: "Engineering", url: "http://schedules.calpoly.edu/depts_52-CENG_next.htm"},
              { college_name: "Science & Mathematics", url: "http://schedules.calpoly.edu/depts_76-CSM_next.htm"} ]

    urls.each do |url|
      college_name = url[:college_name].to_s
      puts "=================================================="
      puts college_name.upcase
      puts "=================================================="
      html_document ||= Nokogiri::HTML(open(url[:url], {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))
      current_instructor = "UNKNOWN"
      html_document.css("tr").each do |tr|
        if tr.at_css("td.courseName")
          if tr.at_css("td.personName")
            current_instructor = tr.at_css("td.personName").text.strip
          end
          course = tr.at_css("td.courseName").text.gsub(/\s*\(\d+\)/, "").strip
          section = tr.at_css("td.courseSection").text.strip
          type = tr.at_css("td.courseType").text.strip
          days = tr.at_css("td.courseDays").text.strip
          start_time = tr.at_css("td.startTime").text.strip
          end_time = tr.at_css("td.endTime").text.strip
          location = tr.at_css("td.location").text.strip
          next if type == "Ind"
          printf("|%15s|%5s|%7s|%5s|%10s - %-10s|%12s|%32s|\n", course, section, type, days, start_time, end_time, location, current_instructor)

          insert_data = {
            college_name: college_name,
            course_name: course,
            section: section,
            type: type,
            days: days,
            start_time: start_time,
            end_time: end_time,
            location: location,
            instructor: current_instructor,
            timestamp: Time.now.to_i
          }
          db[MONGO_COLLECTION_NAME].insert_one(insert_data)
        end
      end
    end

  end
end
