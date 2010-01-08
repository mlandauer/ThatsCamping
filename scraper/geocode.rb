#!/usr/bin/env ruby

# Use the names loaded by create_gnr_db.rb and the places loaded by scraper.rb to geocode those parks and campsites
# and update the database with the geocoded locations

require 'poi_location'
require 'park'
require 'campsite'
require 'db'

# Turn a name like "Smith Campground" into "Smith"
def remove_name_ending(name)
  special_phrases = ["large group campground", "picnic and camping area", "camping and picnic area", "campground", "campgrounds", "camping area", "camping ground", "camping grounds", "camp"]
  shorter = name
  special_phrases.each do |phrase|
    shorter = shorter.sub(Regexp.new("\\b#{phrase}\\b", true), "")
  end
  shorter
end

multiple_match_count, no_match_count, match_count = 0, 0, 0
Campsite.find(:all).each do |campsite|
  match_text = remove_name_ending(campsite.name)
  puts "#{campsite.name} -> #{match_text}"
  #puts match_text
  #matches = PoiLocation.find(:all, :conditions => ["name LIKE ?", "%#{match_text}%"])
  #if matches.size > 1
  #  puts "Multiple matches for: #{campsite.name}"
  #  multiple_match_count += 1
  #elsif matches.size == 0
  #  puts "No match for: #{campsite.name}"
  #  no_match_count += 1
  #else
  #  puts "Unique match: #{campsite.name} matches #{matches.first.name}"
  #  match_count += 1
  #end
end

puts "\nStatistics on matches: multiple: #{multiple_match_count}, no: #{no_match_count}, match: #{match_count}"