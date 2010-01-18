#!/usr/bin/env ruby
# Create the database structure that we want

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'activerecord'
require 'db'

ActiveRecord::Schema.define do
  create_table :parks do |t|
    t.column :web_id, :string
    t.column :name, :string
  end

  create_table :campsites do |t|
    t.column :web_id, :string
    t.column :name, :string
    t.column :latitude, :float
    t.column :longitude, :float
    t.column :park_id, :integer
    t.column :toilets, :string
    t.column :picnic_tables, :boolean
    t.column :barbecues, :string
    t.column :showers, :string
    t.column :drinking_water, :boolean
    # A long walk or short walk from the car to the camp site?
    t.column :length_walk, :string
    # Suitable for caravans or trailers or car camping?
    t.column :caravans, :boolean
    t.column :trailers, :boolean
    t.column :car, :boolean
    t.column :road_access, :text
    t.column :fees, :text
    t.column :no_sites, :integer
    t.column :description, :text
  end

  # Location data (can be sourced from multiple locations)
  create_table :locations do |t|
    t.column :name, :string
    t.column :latitude, :float
    t.column :longitude, :float
    t.column :source_id, :integer
  end
  add_index :locations, :name

  # Describes the source a piece of location data (usually just a website)
  create_table :sources do |t|
    t.column :name, :string
    t.column :url, :string
    t.column :last_updated, :timestamp
  end
  add_index :sources, :name, :unique => true
end
