#!/usr/bin/env ruby

# Use the names loaded by create_gnr_db.rb and the places loaded by scraper.rb to geocode those parks and campsites
# and update the database with the geocoded locations

require 'name'
require 'park'
require 'campsite'
require 'db'

#Park.find(:all).each do |park|
#  matches = Name.find(:all, :conditions => "name LIKE '%#{park.name}%'")
#  if matches.size > 1
#    puts "Multiple matches for: #{park.name}"
#  elsif matches.size == 0
#    puts "No match for: #{park.name}"
#  end
#  #p park.name, Name.find(:
#end

Campsite.find(:all).each do |campsite|
  match_text = campsite.name.downcase.gsub("campground", "").gsub("camping area", "").gsub("camping ground", "").strip
  matches = Name.find(:all, :conditions => "name LIKE '%#{match_text}%'")
  if matches.size > 1
    puts "Multiple matches for: #{match_text}"
  elsif matches.size == 0
    puts "No match for: #{match_text}"
  end
end