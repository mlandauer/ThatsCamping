#!/usr/bin/env ruby

# Scrapes more details about campsites. This can only be run after "scraper.rb"

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'mechanize'
require 'db'
require 'park'
require 'campsite'

agent = WWW::Mechanize.new

Park.find(:all).each do |park|
  puts "Processing page #{park.campsites_url}..."
  page = agent.get(park.campsites_url)

  a = page.at('div > a[@name]')

  results = {}
  while a
    content = a.next
    a2 = content.search('a[@name]').find{|t| t.attributes['name'].to_s[0..0] == 'c'}
    if a2
      content2 = a2.next
      content.add_next_sibling(a2)
      a2.add_next_sibling(content2)
      results[a.attributes['name'].to_s] = content
    end
    a = a2
  end

  results.each do |web_id, result|
    site = Campsite.find(:first, :conditions => {:web_id => web_id})
    if site.nil?
      puts "WARNING: Strange. Can't find campsite with web_id: #{web_id}. So, skipping"
    else
      road_access_heading = result.at('#relatedLinks').search('.heading').find{|h| h.inner_text == "Road access"}
      site.road_access = road_access_heading.next.inner_text.strip if road_access_heading
      fees = result.at('#relatedLinks').search('.heading').find{|h| h.inner_text == "Fees"}
      if fees
        site.fees = ""
        current = fees.next
        while current
          site.fees += current.to_s
          current = current.next
        end
      end
      if result.at('h3').inner_text.strip =~ /\((\d+) sites\)/
        site.no_sites = $~[1].to_i
      end
      site.save!
    end
  end
end

Park.find(:all, :order => :name).each do |park|
  puts "#{park.name}:"
  park.campsites(:order => :name).each do |s|
    puts "  #{s.name}, No sites: #{s.no_sites}, Facilities: #{s.toilets}, #{s.picnic_tables}, #{s.barbecues}, #{s.showers}, #{s.drinking_water}, Length walk: #{s.length_walk}, Caravans: #{s.caravans}, Trailers: #{s.trailers}, Car: #{s.car}"
  end
end
