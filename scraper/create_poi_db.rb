#!/usr/bin/env ruby

# Reads in data from Garmen CSV file from http://www.poidb.com and puts it in a database

require 'rubygems'
require 'fastercsv'
require 'activerecord'
require 'db'
require 'poi_location'

# Create the database structure that we want
ActiveRecord::Schema.define do
  create_table "poi_locations", :force => true do |t|
    t.column :name, :string
    t.column :latitude, :float
    t.column :longitude, :float
  end
end
  
data = FasterCSV.read("#{File.dirname(__FILE__)}/data/campgrounds_and_rest_areas_nsw_poidb.com.csv")
data.each do |row|
  longitude, latitude, name = row
  PoiLocation.new(:name => name, :latitude => latitude, :longitude => longitude).save!  
  puts "name: #{name}, position: #{latitude}, #{longitude}"
end
