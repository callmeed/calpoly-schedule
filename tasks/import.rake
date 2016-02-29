require 'open-uri'
require 'rubygems'
require 'openssl'
require 'nokogiri'
require 'mongo'
require 'json'

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

  desc "Cleanup JSON files and add []s to make them valid arrays"
  task :clean do
    Dir.chdir(File.join(File.dirname(__FILE__),"..","data"))
    Dir.glob("*.json").each do |f|
      File.open(f, "a+:UTF-8") {|file| file.write("]\n")}
    end
    #  = File.join(File.dirname(__FILE__),"..","data","#{dept}.json")
    # File.open(filename, "a+") do |f|
    #   f.write("\t" + insert_data.to_json + ",\n")
    # end
  end

  desc 'Import courses from schedules.calpoly.edu'
  task :courses do

    # Mongo connection
    # db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => MONGO_DB_NAME)

    # These are all the different college schedule URLs
    urls = [ { college_name: "Engineering", url: "http://schedules.calpoly.edu/depts_52-CENG_next.htm"},
             { college_name: "Science & Mathematics", url: "http://schedules.calpoly.edu/depts_76-CSM_next.htm"},
             { college_name: "Agriculture, Food & Environmental Science", url: "http://schedules.calpoly.edu/depts_10-CAGR_next.htm"},
             { college_name: "Architecture & Environmental Design", url: "http://schedules.calpoly.edu/depts_20-CAED_next.htm"},
             { college_name: "Business", url: "http://schedules.calpoly.edu/depts_40-OCOB_next.htm"},
             { college_name: "Liberal Arts", url: "http://schedules.calpoly.edu/depts_40-OCOB_next.htm"} ]

    course_list = {}

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
          course = tr.at_css("td.courseName").text.gsub(/\s*\(\d+\)/, "").gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
          dept   = course.match(/^[a-zA-Z]+/)[0]
          section = tr.at_css("td.courseSection").text.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
          type = tr.at_css("td.courseType").text.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
          days = tr.at_css("td.courseDays").text.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
          start_time = tr.at_css("td.startTime").text.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
          end_time = tr.at_css("td.endTime").text.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
          location = tr.at_css("td.location").text.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
          next if type == "Ind"
          printf("|%7s|%15s|%5s|%7s|%5s|%10s - %-10s|%12s|%32s|\n", dept, course, section, type, days, start_time, end_time, location, current_instructor)

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
          }



          if !course_list.has_key? dept
            course_list[dept] = []
          end

          course_list[dept] << insert_data

          # Uncomment this if you want to write it to your mongo db
          # db[MONGO_COLLECTION_NAME].insert_one(insert_data)
        end
      end
    end
    # If the file doesn't exist create it and add an opening [
    course_list.each do |key, value|
      filename = File.join(File.dirname(__FILE__),"..","data","#{key}.json")
      File.open(filename, "a+:UTF-8") do |f|
        f.write(JSON.pretty_generate(value, indent: "\t"))
      end
    end
  end
end
