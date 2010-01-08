#!/usr/bin/env ruby

# Reads in data from Garmen CSV file from http://www.poidb.com and puts it in a database

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'fastercsv'
require 'activerecord'
require 'mechanize'
# Using the following for doing bulk inserts into db
require 'ar-extensions'

require 'db'
require 'location'
require 'source'

# Prepare the source
source = Source.new(:name => "poidb", :url => "http://www.poidb.com")
source.save!

# Filename for csv file
filename = "#{File.dirname(__FILE__)}/data/poi.csv"

# Download the data and write it to local file. Note that there is a download limit of 5 times for unregistered users
#agent = WWW::Mechanize.new
#page = agent.get("http://www.poidb.com/groups/download_group_poi_new.asp?GroupID=526&format=csv&filter=2_0&EmailAlert=0&titleformat=1&AppendPhone=0")
#File.open(filename, "w") {|f| f.write(page.body)}

Location.import [:longitude, :latitude, :name, :source_id],
  FasterCSV.read(filename).map {|row| row + [source.id]}

# Update the timestamp on the source
source.last_updated = Time.now
source.save!

