#!/usr/bin/env ruby

# Output the contents of the database to a property list than can be used by the application

require 'rubygems'
require 'builder'

File.open("#{File.dirname(__FILE__)}/../Parks.plist", "w") do |f|
  x = Builder::XmlMarkup.new(:target => f, :indent => 2)
  x.instruct!
  x.declare! :DOCTYPE, :plist, :PUBLIC, "-//Apple//DTD PLIST 1.0//EN", "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
  x.plist(:version => "1.0") {
    x.array {
      x.dict {
        x.key "name"
        x.string "Blue Mountains"
        x.key "webId"
        x.string "BLUE"
      }
      x.dict {
        x.key "name"
        x.string "Kanangra-Boyd"
        x.key "webId"
        x.string "KAN"
      }    
    }
  }
end

File.open("#{File.dirname(__FILE__)}/../Campsites.plist", "w") do |f|
  x = Builder::XmlMarkup.new(:target => f, :indent => 2)
  x.instruct!
  x.declare! :DOCTYPE, :plist, :PUBLIC, "-//Apple//DTD PLIST 1.0//EN", "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
  x.plist(:version => "1.0") {
    x.array {
      x.dict {
        x.key "name";       x.string  "Perrys Lookdown"
        x.key "latitude";   x.real    -33.598333
    		x.key "longitude";  x.real    150.351111
    		x.key "webId";      x.string  "foo"
    		x.key "parkWebId";  x.string  "BLUE"
      }
      x.dict {
    		x.key "name";       x.string  "Euroka Clearing"
    		x.key "latitude";   x.real    -33.798333
    		x.key "longitude";  x.real    150.617778
    		x.key "webId";      x.string  "foo"
    		x.key "parkWebId";  x.string  "BLUE"
    	}
    	x.dict {
    		x.key "name";       x.string  "Murphys Glen"
    		x.key "latitude";   x.real    -33.765
    		x.key "longitude";  x.real    150.501111
    		x.key "webId";      x.string  "foo"
    		x.key "parkWebId";  x.string  "BLUE"
    	}
    	x.dict {
    		x.key "name";       x.string  "Dingo Dell"
    		x.key "latitude";   x.real    -33.97375
    		x.key "longitude";  x.real    149.96516
    		x.key "webId";      x.string  "foo"
    		x.key "parkWebId";  x.string  "KAN"
    	}
    	x.dict {
    		x.key "name";       x.string  "Boyd River"
    		x.key "webId";      x.string  "foo"
    		x.key "parkWebId";  x.string  "KAN"
    	}
    }
  }
end