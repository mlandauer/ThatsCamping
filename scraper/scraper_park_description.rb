#!/usr/bin/env ruby

# Extract description of parks

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'mechanize'
require 'park'
require 'db'
require 'find_consecutive'
require 'utils'

agent = WWW::Mechanize.new

Park.find(:all).each do |park|
  page = agent.get("http://www.environment.nsw.gov.au/NationalParks/parkHome.aspx?id=#{park.web_id}")
  description = html_into_plain_text("<div>" + page.search('div#deccAppUcUc1_ParkVisPageIntro').children.find_consecutive{|t| t.at('strong').nil?}.join + "</div>")
  puts "*** #{park.name} ***"
  puts description
  park.description = description
  park.save!
end