#!/usr/bin/env ruby

# Read the data from the Geographical Names Register CSV files and write them to an sqlite db so we can do some quick lookups

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'fastercsv'
require 'activerecord'
require 'mechanize'
require 'zip/zipfilesystem'
# Using the following for doing bulk inserts into db
require 'ar-extensions'

require 'location'
require 'db'

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
  puts "Reading in CSV file #{file}..."
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

def download_data
  filename = "#{File.dirname(__FILE__)}/data/gnr.zip"

  # Only download the file if it doesn't already exist
  unless File.exists?(filename)
    puts "Downloading data from web site..."
    agent = WWW::Mechanize.new
    page = agent.get("http://www.gnb.nsw.gov.au/__gnb/gnr.zip")
    File.open(filename, "w") {|f| f.write(page.body)}
  end

  Zip::ZipFile.foreach(filename) do |entry|
    entry_path = "#{File.dirname(__FILE__)}/data/#{entry.name}"
    unless File.exists?(entry_path)
      puts "Extracting file..."
      entry.extract(entry_path)
    end
  end
end

def prepare_source(name, url)
  source = Source.find(:first, :conditions => {:name => name})
  if source
    # Zap all the old data
    Location.delete_all(:source_id => source.id)
  else
    source = Source.new(:name => name, :url => url)
    source.save!
  end
  source
end

download_data

rows = read_csv("#{File.dirname(__FILE__)}/data/gnr_part1.csv")
rows += read_csv("#{File.dirname(__FILE__)}/data/gnr_part2.csv")

puts "Converting latitude and longitude format..."
converted = []
rows.each do |row|
  # Convert from degrees, minutes, seconds
  latitude = convert_degrees_mins(row[1])
  longitude = convert_degrees_mins(row[2])
  converted << [row[0], latitude, longitude] if latitude && longitude
end

puts "Importing into database..."
source = prepare_source("gnr", "http://www.gnb.nsw.gov.au/")
Location.import [:name, :latitude, :longitude, :source_id], converted.map{|a| a + [source.id]}
# Update the timestamp on the source
source.last_updated = Time.now
source.save!
