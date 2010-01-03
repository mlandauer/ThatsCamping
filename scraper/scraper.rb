#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'simple_struct'
require "activerecord"

# Establish the connection to the database
ActiveRecord::Base.establish_connection(
        :adapter  => "sqlite3",
        :database => File.join(File.dirname(__FILE__), "data", "thatscampin.db")
)

#ActiveRecord::Base.logger = Logger.new(STDOUT)

class Park < ActiveRecord::Base
  has_many :campsites
  
  def url
    "http://www.environment.nsw.gov.au/NationalParks/parkHome.aspx?id=#{web_id}"
  end
  
  def campsites_url
    "http://www.environment.nsw.gov.au/NationalParks/parkCamping.aspx?id=#{web_id}"
  end
end

class Campsite < ActiveRecord::Base
  has_one :park

  def url
    "#{park.campsites_url}##{web_id}"
  end
end

agent = WWW::Mechanize.new

if true
  # Create the database structure that we want
  ActiveRecord::Schema.define do
    create_table "parks", :force => true do |t|
      t.column :web_id, :string
      t.column :name, :string
    end
  
    create_table "campsites", :force => true do |t|
      t.column :web_id, :string
      t.column :name, :string
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
    end
  end

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
end

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
