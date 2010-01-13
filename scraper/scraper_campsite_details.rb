#!/usr/bin/env ruby

# Scrapes more details about campsites. This can only be run after "scraper.rb"

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'mechanize'
require 'db'
require 'park'
require 'campsite'

agent = WWW::Mechanize.new

def paragraphs_after_heading(result)
  ret = []
  current = result.at('h3').next
  while current
    ret << current unless current.inner_html.strip == ""
    current = current.next
  end
  ret
end

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
    puts "Campsite: #{site.name}"
    p result
    exit
    if site.nil?
      #puts "WARNING: Strange. Can't find campsite with web_id: #{web_id}. So, skipping"
    else
      description = Nokogiri::HTML.fragment(paragraphs_after_heading(result).find_all{|p| p.at('strong').nil?}.map{|p| p.to_s}.join)
      # Remove images and links associated with them
      description.search('a > img').each{|i| i.parent.remove}
      description.search('img').remove
      p description
      puts "<h2>#{site.name}</h2>"
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
