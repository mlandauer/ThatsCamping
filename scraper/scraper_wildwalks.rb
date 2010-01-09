#!/usr/bin/env ruby

# Scrape http://www.wildwalks.com for the location (latitude / longitude) of campsites

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'mechanize'
require 'utils'
require 'db'
require 'park'

agent = WWW::Mechanize.new

def extract_urls_from_areas_page(page)
  page.at('table.contentpaneopen').search('a').map{|a| a.attributes['href']}
end

# Returns an array of the form [[park_name, campsite_name, campsite_url], ...]
def extract_data_from_area_page(page)
  data = []
  # Extract the urls and names of campsites on this page
  # Start at the first park name
  tag = page.search('table.contentpaneopen')[1].at('a[@name]').parent
  park_name = nil
  begin
    if tag.at('a[@name]')
      # This is a park name
      park_name = tag.at('a[@name]').inner_text.strip
    else
      if tag.at('a')
        campsite_name = tag.at('a').inner_text.strip
        campsite_url = tag.at('a').attributes['href']
        data << [park_name, campsite_name, campsite_url]
      else
        puts "WARNING: Skipping \"#{tag.at('td').inner_text.strip}\" because no link"
      end
    end
  end while tag = tag.next
  data
end

# Returns data of the form [latitude, longitude]
def extract_data_from_campsite_page(page)
  # Assume the first tab is always the one we're interested in
  if page.at('div.jwts_tabbertab').inner_text =~ /GPS: Latitude (.*) Longitude (.*)/
    $~[1..2]
  end
end

def parse_angle(text, positive_char, negative_char)
  values = text.split(" ").map{|t| t.to_f}
  case text.strip[-1..-1]
  when positive_char
    convert_degrees_mins(values[0], values[1], values[2])
  when negative_char
    convert_degrees_mins(-values[0], values[1], values[2])
  else
    raise "Unexpected direction in #{text}"    
  end
end

def parse_latitude_longitude(lat, long)
  [parse_angle(lat, "N", "S"), parse_angle(long, "E", "W")]
end

data = []
extract_urls_from_areas_page(agent.get("http://www.wildwalks.com/office/office/camping.html")).each do |area_url|
  puts "Scraping data on #{area_url}..."
  data += extract_data_from_area_page(agent.get(area_url))
end

data.each do |campsite_data|
  park_name = campsite_data[0]
  campsite_name = campsite_data[1]
  campsite_url = campsite_data[2]

  #puts "Park: #{park_name}, Campsite: #{campsite_name}"
  park = Park.find(:first, :conditions => {:name => park_name})
  if park
    campsite = park.campsites.find(:first, :conditions => {:name => campsite_name})
    if campsite.nil?
      names = park.campsites.map{|c| c.name}
      puts "WARNING: Couldn't find campsite: #{campsite_name}. Possible matches: #{names.join(', ')}"
    end
  else
    puts "WARNING: Couldn't find park: #{park_name}"
  end
  
  #data = extract_data_from_campsite_page(agent.get(campsite_url))
  #if data
  #  latitude, longitude = parse_latitude_longitude(data[0], data[1])
  #  puts "Park: #{park_name}, Campsite: #{campsite_name}, Position: #{latitude}, #{longitude}"
  #else
  #  puts "WARNING: No GPS data found for park: #{park_name}, campsite: #{campsite_name}"
  #end
end

