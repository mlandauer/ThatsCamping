#!/usr/bin/env ruby

# Reads in data from Garmen CSV file from http://www.poidb.com and puts it in a database

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'fastercsv'
require 'activerecord'
require 'mechanize'

require 'db'
require 'location'
require 'source'

# Create the database structure that we want
ActiveRecord::Schema.define do
  create_table "locations", :force => true do |t|
    t.column :name, :string
    t.column :latitude, :float
    t.column :longitude, :float
    t.column :source_id, :integer
  end
  
  # Describes the source a piece of location data (usually just a website)
  create_table "sources", :force => true do |t|
    t.column :name, :string
    t.column :url, :string
    t.column :last_updated, :timestamp
    t.add_index :name, :unique => true
  end
end

# Prepare the source
source = Source.new(:name => "poidb", :url => "http://www.poidb.com")
source.save!

# Filename for csv file
filename = "#{File.dirname(__FILE__)}/data/poi.csv"

# Download the data and write it to local file. Note that there is a download limit of 5 times for unregistered users
#agent = WWW::Mechanize.new
#page = agent.get("http://www.poidb.com/groups/download_group_poi_new.asp?GroupID=526&format=csv&filter=2_0&EmailAlert=0&titleformat=1&AppendPhone=0")
#File.open(filename, "w") {|f| f.write(page.body)}

data = FasterCSV.read(filename)
data.each do |row|
  l = Location.new(:name => row[2], :latitude => row[1], :longitude => row[0], :source => source)
  l.save!
  puts "name: #{l.name}, position: #{l.latitude}, #{l.longitude}"
end

# Update the timestamp on the source
source.last_updated = Time.now
source.save!

