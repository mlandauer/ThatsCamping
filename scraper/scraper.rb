#!/usr/bin/env ruby

# TODO: There's a problem here "Bombah Broadwater: campgrounds on the eastern    shore"

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'mechanize'
require 'simple_struct'
require "activerecord"

require 'park'
require 'campsite'
require 'db'

def extract_campsite_content(a_tag)
  finished = false
  result = []
  a_tag.next.children.each do |c|
    if c.matches?('a[@name]')
      finished = true
    elsif !finished
      result << c
    end
  end
  result
end

def simplify_whitespace(text)
  text.gsub(/[\n\t\r]/, " ").squeeze(" ").strip
end

# First zap all the parks and campsites data
Park.delete_all
Campsite.delete_all

#ActiveRecord::Base.logger = Logger.new(STDOUT)

agent = WWW::Mechanize.new

page = agent.get("http://www.environment.nsw.gov.au/NationalParks/SearchCampgrounds.aspx")
page = page.form_with(:name => "campgroundsSearch").submit

page.search('#SearchResults')[1].search('tr')[1..-1].each do |camp|
  park_name = camp.search('td')[3].inner_text.strip
  park_url = (page.uri + URI.parse(camp.search('td')[3].at('a').attributes['href'])).to_s
  if park_url =~ /^http:\/\/www\.environment\.nsw\.gov\.au\/NationalParks\/parkHome\.aspx\?id=(\w+)$/
    park_web_id = $~[1]
  else
    raise "Unexpected form for park_url: #{park_url}"
  end
  # Find, otherwise create
  park = Park.find(:first, :conditions => {:web_id => park_web_id})
  if park.nil?
    park = Park.new(:name => park_name, :web_id => park_web_id)
    park.save!
  end

  url = (page.uri + URI.parse(camp.search('td')[0].at('a').attributes['href'])).to_s
  if url =~ /^http:\/\/www\.environment\.nsw\.gov\.au\/NationalParks\/parkCamping\.aspx\?id=(\w+)#(\w+)$/
    raise "park web_id does not match" unless $~[1] == park.web_id
    camp_web_id = $~[2]
  else
    raise "Unexpected form for url: #{url}"
  end

  c = Campsite.new(
    :name => camp.search('td')[0].inner_text.strip,
    :web_id => camp_web_id,
    :park_id => park.id
    )
  
  alt_attributes = camp.search('td')[2].search('img').map{|i| i.attributes['alt'].to_s.downcase}
  if alt_attributes.empty?
    description = camp.search('td')[2].inner_text.strip.downcase
    case description
    when "long walk from car to tent"
      c.length_walk = "long"
      c.caravans = false
      c.trailers = false
      c.car = false
    when "short walk from car to tent"
      c.length_walk = "short"
      c.caravans = false
      c.trailers = false
      c.car = false
    else
      raise "Unexpected text: #{description}"
    end
  else
    c.length_walk = "none"
    alt_attributes.each do |text|
      case text
      when "suitable for caravans"
        c.caravans = true
      when "not suitable for caravans"
        c.caravans = false
      when "suitable for camper trailers"
        c.trailers = true
      when "not suitable for camper trailers"
        c.trailers = false
      when "suitable for camping beside your car"
        c.car = true
      else
        raise "Unexpected text: #{text}"
      end
    end
  end

  camp.search('td')[1].search('img').map{|i| i.attributes['alt'].to_s.downcase}.each do |text|
    case text
    when "non-flush toilets"
      c.toilets = "non_flush"
    when "flush toilets"
      c.toilets = "flush"
    when "no toilets"
      c.toilets = "none"
    when "no picnic tables"
      c.picnic_tables = false
    when "picnic tables"
      c.picnic_tables = true
    when "no barbecues"
      c.barbecues = "none"
    when "wood barbecues", 
      c.barbecues = "wood"
    when "wood barbecues (firewood supplied)"
      c.barbecues = "wood_supplied"
    # Not recording that the BBQs are free
    when "gas/electric barbecues", "gas/electric barbecues (free)"
      c.barbecues = "gas_electric"
    when "wood barbecues (bring your own firewood)"
      c.barbecues = "wood_bring_your_own"
    when "no showers"
      c.showers = "none"
    when "hot showers"
      c.showers = "hot"
    when "cold showers"
      c.showers = "cold"
    when "no drinking water"
      c.drinking_water = false
    when "drinking water"
      c.drinking_water = true
    else
      raise "Unexpected text description: #{text}"
    end
  end
  c.save!
end

# Now fix up a few problems by hand
# TODO: It would be good to automate some of this

c = Campsite.find(:first, :conditions => {:name => "Boat-based campgrounds"})
# This campsite is just a wrapper for a bunch of other campsites. We're going to add these by hand

sites = []
sites << Campsite.new(:name => "Brambles Green", :no_sites => 2, :toilets => "none")
sites << Campsite.new(:name => "Rivermouth", :no_sites => 5, :toilets => "non_flush")
sites << Campsite.new(:name => "Joes Cove", :no_sites => 2, :toilets => "none")
sites << Campsite.new(:name => "Freshwater", :no_sites => 7, :toilets => "non_flush")
sites << Campsite.new(:name => "Two Mile Sands", :no_sites => 4, :toilets => "none")
sites << Campsite.new(:name => "Mackaway Bay", :no_sites => 3, :toilets => "none")
sites << Campsite.new(:name => "Johnsons Beach", :no_sites => 17, :toilets => "non_flush")
sites << Campsite.new(:name => "Shelly Beach", :no_sites => 18, :toilets => "non_flush")
sites << Campsite.new(:name => "Sunny Side", :no_sites => 4, :toilets => "none")
# Set attributes common to these campsites
sites.each do |site|
  site.web_id = c.web_id
  site.park_id = c.park_id
  site.drinking_water = false
  site.picnic_tables = false
  site.barbecues = "none"
  site.showers = "none"
  site.caravans = false
  site.trailers = false
  site.car = false
  site.length_walk = "none"
  site.road_access = "only accessible by boat"
  # TODO: Haven't filled in fees
  site.save!
end

c.delete
