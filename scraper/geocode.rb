#!/usr/bin/env ruby

# Use the names loaded by load_gnr_db.rb and load_poi_db and the places loaded by scraper.rb to geocode those
# parks and campsites and update the database with the geocoded locations

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'location'
require 'park'
require 'campsite'
require 'db'

# Turn a name like "Smith Campground" into "Smith"
def remove_name_ending(name)
  special_phrases = ["picnic and camping area", "campground and picnic area", "camping and picnic area", "large group campground",
    "camping ground", "campground", "camping area", "camp", "rest area", "tourist park", "campgrounds", "camping grounds"]
  shorter = name
  special_phrases.each do |phrase|
    shorter = shorter.sub(Regexp.new("\\b#{phrase}$", true), "")
  end
  shorter
end

#campsites = Campsite.find(:all)
# First find any campsites that we can make exact matches for
#campsites.each do |campsite|
#  puts "Checking #{campsite.name}"
#  matches = Location.find(:all, :conditions => ["name LIKE ?", campsite.name])
#  if matches.size == 1
#    puts "Perfect match for: #{campsite.name}"
#    #campsite.delete
#    perfect_match_count += 1
#  elsif matches.size > 1
#    match_names = matches.map{|m| m.name}
#    puts "Multiple matches for #{campsite.name}: #{match_names.join(" or ")}"
#  end
#end
#exit
  
multiple_match_count, no_match_count, match_count = 0, 0, 0
Campsite.find(:all).each do |campsite|
  match_text = remove_name_ending(campsite.name)
  matches = Location.find(:all, :conditions => ["name LIKE ?", "%#{match_text}%"])
  if matches.size > 1
    puts "Multiple matches for: #{campsite.name}"
    multiple_match_count += 1
  elsif matches.size == 0
    puts "No match for: #{campsite.name}"
    no_match_count += 1
  else
    puts "Unique match: #{campsite.name} matches #{matches.first.name}"
    match_count += 1
  end
end

puts "\nStatistics on matches: multiple: #{multiple_match_count}, no: #{no_match_count}, match: #{match_count}"
