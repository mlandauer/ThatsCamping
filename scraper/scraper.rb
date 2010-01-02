require 'rubygems'
require 'mechanize'
require 'simple_struct'

class Park < SimpleStruct
  add_attributes :name, :url
end

class CampSite < SimpleStruct
  add_attributes :name, :url, :park,
    :toilets, :flush_toilets, :picnic_tables, :barbecues, :wood_barbecues, :bring_firewood, :gas_electric_barbecues,
    :showers, :hot_showers, :drinking_water
  # A long walk or short walk from the car to the camp site?
  add_attributes :long_walk, :short_walk
  # Suitable for caravans or trailers or car camping?
  add_attributes :caravans, :trailers, :car
end

agent = WWW::Mechanize.new
page = agent.get("http://www.environment.nsw.gov.au/NationalParks/SearchCampgrounds.aspx")
page = page.form_with(:name => "campgroundsSearch").submit

parks = []
campsites = page.search('#SearchResults')[1].search('tr')[1..-1].map do |camp|
  park_name = camp.search('td')[3].inner_text.strip
  park_url = page.uri + URI.parse(camp.search('td')[3].at('a').attributes['href'])
  park = Park.new(:name => park_name, :url => park_url)
  
  found_park = parks.find{|p| p.name == park.name}
  if found_park
    # Double-check that the url is the same
    raise "Oops. Multiple parks with the same name" unless found_park == park
    park = found_park
  end
  
  c = CampSite.new(
    :name => camp.search('td')[0].inner_text.strip,
    :url => page.uri + URI.parse(camp.search('td')[0].at('a').attributes['href']),
    :park => park
    )
    
  alt_attributes = camp.search('td')[2].search('img').map{|i| i.attributes['alt'].to_s.downcase}
  if alt_attributes.empty?
    description = camp.search('td')[2].inner_text.strip.downcase
    case description
    when "long walk from car to tent"
      c.long_walk = true
    when "short walk from car to tent"
      c.short_walk = true
    else
      raise "Unexpected text: #{description}"
    end
  else
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
      c.toilets = true
      c.flush_toilets = false
    when "flush toilets"
      c.toilets = true
      c.flush_toilets = true
    when "no toilets"
      c.toilets = false
      c.flush_toilets = false
    when "no picnic tables"
      c.picnic_tables = false
    when "picnic tables"
      c.picnic_tables = true
    when "no barbecues"
      c.barbecues = false
      c.wood_barbecues = false
      c.gas_electric_barbecues = false
    when "wood barbecues"
      c.barbecues = true
      c.wood_barbecues = true
      c.gas_electric_barbecues = false
    when "gas/electric barbecues"
      c.barbecues = true
      c.wood_barbecues = false
      c.gas_electric_barbecues = true
    # Not recording that the BBQs are free
    when "gas/electric barbecues (free)"
      c.barbecues = true
      c.wood_barbecues = false
      c.gas_electric_barbecues = true      
    when "wood barbecues (bring your own firewood)"
      c.barbecues = true
      c.wood_barbecues = true
      c.bring_firewood = true
    when "wood barbecues (firewood supplied)"
      c.barbecues = true
      c.wood_barbecues = true
      c.bring_firewood = false      
    when "no showers"
      c.showers = false
      c.hot_showers = false
    when "hot showers"
      c.showers = true
      c.hot_showers = true
    when "cold showers"
      c.showers = true
      c.hot_showers = false
    when "no drinking water"
      c.drinking_water = false
    when "drinking water"
      c.drinking_water = true
    else
      raise "Unexpected text description: #{text}"
    end
  end
  c
end

p campsites