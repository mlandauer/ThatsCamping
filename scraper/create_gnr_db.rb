#!/usr/bin/env ruby

# Read the data from the Geographical Names Register CSV files and write them to an sqlite db so we can do some quick lookups

require 'rubygems'
require 'fastercsv'

def convert_degrees_mins(text)
  if text.strip =~ /^(-?\d+)\s+(-?\d+)\s+(-?\d+)$/
    degrees = $~[1].to_f
    minutes = $~[2].to_f
    seconds = $~[3].to_f
    offset = (minutes + seconds / 60.0) / 60.0
    if degrees < 0
      degrees - offset
    else
      degrees + offset
    end
  end
end

rows = File.open("#{File.dirname(__FILE__)}/data/gnr_part1.csv").map do |line|
  # Parse a line at the time - that gives us a chance to fix up the badly formatted CSV
  split = line.split(",").map do |value|
    if value[0..0] == '"' && value[-1..-1] == '"'
      '"' + value[1..-2].gsub('"', "'") + '"'
    else
      value.gsub('"', '')
    end
  end
  line = split.join(",")
  data = FasterCSV.parse_line(line)
  [data[1], data[11], data[12]]
end

# Get rid of stuff at the beginning
rows = rows[6..-1]

rows.each do |row|
  # Convert from degrees, minutes, seconds
  latitude = convert_degrees_mins(row[1])
  longitude = convert_degrees_mins(row[2])
  if latitude && longitude
    puts "Placename: #{row[0]}, Position: #{latitude}, #{longitude}"
  end
end