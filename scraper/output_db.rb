#!/usr/bin/env ruby

# Output the contents of the database to a property list than can be used by the application

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'builder'
require 'db'
require 'park'
require 'campsite'
require 'utils'

def shorten_park_name(name)
  substitute_phrases_at_end(name,
    {"National Park" => "NP", "State Conservation Area" => "SCA", "Nature Reserve" => "NR", "Karst Conservation Reserve" => "KCR",
      "Historic Site" => ""})
end

def shorten_campsite_name(name)
  # Special handling for one campsite name
  if name == "Euroka campground - Appletree Flat campervan and camper trailer area"
    "Euroka (trailer area)"
  else
    remove_phrases_at_end(name,
      ["campground and picnic area", "picnic and camping area", "camping and picnic area", "large group campground",
      "campground", "camping area", "camping ground", "campgrounds", "tourist park", "camping grounds", "rest area"])
  end
end

File.open("#{File.dirname(__FILE__)}/../Parks.plist", "w") do |f|
  x = Builder::XmlMarkup.new(:target => f, :indent => 2)
  x.instruct!
  x.declare! :DOCTYPE, :plist, :PUBLIC, "-//Apple//DTD PLIST 1.0//EN", "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
  x.plist(:version => "1.0") {
    x.array {
      Park.find(:all).each do |park|
        x.dict {
          puts shorten_park_name(park.name)
          x.key "shortName"; x.string shorten_park_name(park.name)
          x.key "longName"; x.string park.name
          x.key "webId";  x.string park.web_id
        }        
      end
    }
  }
end

File.open("#{File.dirname(__FILE__)}/../Campsites.plist", "w") do |f|
  x = Builder::XmlMarkup.new(:target => f, :indent => 2)
  x.instruct!
  x.declare! :DOCTYPE, :plist, :PUBLIC, "-//Apple//DTD PLIST 1.0//EN", "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
  x.plist(:version => "1.0") {
    x.array {
      Campsite.find(:all).each do |campsite|
        x.dict {
          x.key "shortName"; x.string shorten_campsite_name(campsite.name)
          x.key "longName"; x.string campsite.name
          if campsite.latitude && campsite.longitude
            x.key "latitude"; x.real campsite.latitude
            x.key "longitude"; x.real campsite.longitude
          end
          x.key "webId"; x.string campsite.web_id
          x.key "parkWebId"; x.string campsite.park.web_id
          x.key "toilets"; x.string campsite.toilets
          x.key "picnicTables"; campsite.picnic_tables ? x.true : x.false
          x.key "barbecues"; x.string campsite.barbecues
          x.key "showers"; x.string campsite.showers
          x.key "drinkingWater"; campsite.drinking_water ? x.true : x.false
          x.key "caravans"; campsite.caravans ? x.true : x.false
          x.key "trailers"; campsite.trailers ? x.true : x.false
          x.key "car"; campsite.car ? x.true : x.false
          x.key "description"; x.string campsite.description
        }
      end
    }
  }
end