#!/usr/bin/env ruby

# Read the data from the Geographical Names Register CSV files and write them to an sqlite db so we can do some quick lookups

require 'rubygems'
require 'fastercsv'
require 'activerecord'

# Establish the connection to the database
ActiveRecord::Base.establish_connection(
        :adapter  => "sqlite3",
        :database => File.join(File.dirname(__FILE__), "data", "thatscampin.db")
)

# Create the database structure that we want
ActiveRecord::Schema.define do
  create_table "names", :force => true do |t|
    t.column :name, :string
    t.column :latitude, :float
    t.column :longitude, :float
  end
end

class Name < ActiveRecord::Base
end

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

def read_csv(file)
  rows = File.open(file).map do |line|
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
  rows[6..-1]
end

rows = read_csv("#{File.dirname(__FILE__)}/data/gnr_part1.csv")
rows += read_csv("#{File.dirname(__FILE__)}/data/gnr_part2.csv")

rows.each do |row|
  # Convert from degrees, minutes, seconds
  latitude = convert_degrees_mins(row[1])
  longitude = convert_degrees_mins(row[2])
  if latitude && longitude
    puts "Placename: #{row[0]}, Position: #{latitude}, #{longitude}"
    name = Name.new(:name => row[0], :latitude => latitude, :longitude => longitude)
    name.save!
  end
end