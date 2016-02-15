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
    course = tr.at_css("td.courseName").text.gsub(/\s*\(\d+\)/, "").strip
    section = tr.at_css("td.courseSection").text.strip
    type = tr.at_css("td.courseType").text.strip
    days = tr.at_css("td.courseDays").text.strip
    start_time = tr.at_css("td.startTime").text.strip
    end_time = tr.at_css("td.endTime").text.strip
    location = tr.at_css("td.location").text.strip
    next if type == "Ind"
    printf("|%15s|%5s|%7s|%5s|%10s - %-10s|%12s|\n", course, section, type, days, start_time, end_time, location)
  end
end
