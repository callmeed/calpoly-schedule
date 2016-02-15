#!/usr/bin/ruby

require 'open-uri'
require 'rubygems'
require 'openssl'
require 'nokogiri'

puts "SCRAPING ..."

@url = "http://schedules.calpoly.edu/depts_52-CENG_next.htm"
@html_document ||= Nokogiri::HTML(open(@url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))

@html_document.css("tr").each do |tr|
  if tr.at_css("td.courseName")
    course = tr.at_css("td.courseName").text
    section = tr.at_css("td.courseSection").text
    type = tr.at_css("td.courseType").text
    days = tr.at_css("td.courseDays").text
    start_time = tr.at_css("td.startTime").text
    end_time = tr.at_css("td.endTime").text
    location = tr.at_css("td.location").text
    next if type == "Ind"
    printf("|%15s|%5s|%7s|%5s|%10s - %-10s|%12s|\n", course, section, type, days, start_time, end_time, location)
  end
end
