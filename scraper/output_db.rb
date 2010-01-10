#!/usr/bin/env ruby

# Output the contents of the database to a property list than can be used by the application

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'builder'
require 'db'
require 'park'
require 'campsite'

File.open("#{File.dirname(__FILE__)}/../Parks.plist", "w") do |f|
  x = Builder::XmlMarkup.new(:target => f, :indent => 2)
  x.instruct!
  x.declare! :DOCTYPE, :plist, :PUBLIC, "-//Apple//DTD PLIST 1.0//EN", "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
  x.plist(:version => "1.0") {
    x.array {
      Park.find(:all).each do |park|
        x.dict {
          x.key "name";   x.string park.name
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
          x.key "name"; x.string campsite.name
          if campsite.latitude && campsite.longitude
            x.key "latitude"; x.real campsite.latitude
            x.key "longitude"; x.real campsite.longitude
          end
          x.key "webId"; x.string campsite.web_id
          x.key "parkWebId"; x.string campsite.park.web_id
        }
      end
    }
  }
end