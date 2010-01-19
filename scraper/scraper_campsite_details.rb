#!/usr/bin/env ruby

# Scrapes more details about campsites. This can only be run after "scraper.rb"

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'mechanize'
require 'db'
require 'park'
require 'campsite'
require 'utils'
require 'find_consecutive'

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

def replace_with_inside(a)
  a.children.each do |c|
    c.parent = a.parent
  end
  a.remove
end

Park.find(:all).each do |park|
  #puts "Processing page #{park.campsites_url}..."
  page = agent.get(park.campsites_url)

  a = page.at('div > a[@name]')
  raise "A problem" unless a.attributes['name'].to_s[0..0] == 'c'
  results = {}
  while a
    content = a.next
    content.search('div.footer').remove
    a2 = content.search('a[@name]').find{|t| t.attributes['name'].to_s[0..0] == 'c'}
    if a2
      content2 = a2.next
      a2.parent = content.parent
      content2.parent = content.parent
      #results[a.attributes['name'].to_s] = content
    end
    a = a2
  end

  # Now that we've untangled the sections, step through them
  results = page.search('a[@name]').find_all{|t| t.attributes['name'].to_s[0..0] == 'c'}.map do |a|
    web_id = a.attributes['name'].to_s
    content = a.next

    site = Campsite.find(:first, :conditions => {:web_id => web_id})
    if site.nil?
      puts "WARNING: Strange. Can't find campsite with web_id: #{web_id}. So, skipping"
    else
      puts "*** #{site.name} ***"
      content.at('div#relatedLinks').remove
      content.at('h3').remove
      description = html_into_plain_text("<div>" + content.children.find_consecutive{|p| p.at('strong').nil? }.join + "</div>")
      puts description
      raise "Found tag" if description =~ /<.*>/
      site.description = description
      site.save!
    end
  end
end
