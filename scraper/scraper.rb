require 'rubygems'
require 'mechanize'
require 'simple_struct'

class Park < SimpleStruct
  add_attributes :name, :id
  
  def url
    "http://www.environment.nsw.gov.au/NationalParks/parkHome.aspx?id=#{id}"
  end
end

class CampSite < SimpleStruct
  add_attributes :id, :name, :park, :toilets, :picnic_tables, :barbecues, :showers, :drinking_water
  # A long walk or short walk from the car to the camp site?
  add_attributes :length_walk
  # Suitable for caravans or trailers or car camping?
  add_attributes :caravans, :trailers, :car
  
  def url
    "http://www.environment.nsw.gov.au/NationalParks/parkCamping.aspx?id=#{park.id}##{id}"
  end
  
  def pretty_print
    if id.nil? || name.nil? || park.nil? || toilets.nil? || picnic_tables.nil? || barbecues.nil? || showers.nil? ||
      drinking_water.nil? || length_walk.nil? || caravans.nil? || trailers.nil? || car.nil?
      p attributes_get.find_all{|k,v| v.nil?}.map{|k,v| k}
      raise "Attribute is nil"
    end
    
    facilities = []
    facilities << case toilets
    when :flush
      "Flush toilets"
    when :non_flush
      "Non-flush toilets"
    else
      "No toilets"
    end
    facilities << (picnic_tables ? "Picnic tables" : "No picnic tables")
    facilities << case barbecues
    when :gas_electric
      "Gas/Electric barbecues"
    when :wood_bring_your_own
      "Wood barbecues (bring your own firewood)"
    when :wood_supplied
      "Wood barbecues (firewood provided)"
    when :wood
      "Wood barbecues"
    else
      "No barbecues"
    end
    facilities << case showers
    when :hot
      "Hot showers"
    when :cold
      "Cold showers"
    else
      "No showers"
    end
    facilities << (drinking_water ? "Drinking water" : "No drinking water")
    access = []
    access << (caravans ? "Caravan camping" : "No caravan camping")
    access << (trailers ? "Trailer camping" : "No trailer camping")
    access << (car ? "Car camping" : "No car camping")
    if length_walk == :long
      access << "Long walk from car to camp site"
    elsif length_walk == :short
      access << "Short walk from car to camp site"
    else
      access << "No walk from car to camp site"
    end
    "Name: #{name}, Park: #{park.name}, Facilities: #{facilities.join(', ')}, Access: #{access.join(', ')}"
  end
end

agent = WWW::Mechanize.new
page = agent.get("http://www.environment.nsw.gov.au/NationalParks/SearchCampgrounds.aspx")
page = page.form_with(:name => "campgroundsSearch").submit

parks = []
campsites = page.search('#SearchResults')[1].search('tr')[1..-1].map do |camp|
  park_name = camp.search('td')[3].inner_text.strip
  park_url = (page.uri + URI.parse(camp.search('td')[3].at('a').attributes['href'])).to_s
  if park_url =~ /^http:\/\/www\.environment\.nsw\.gov\.au\/NationalParks\/parkHome\.aspx\?id=(\w+)$/
    park_id = $~[1]
  else
    raise "Unexpected form for park_url: #{park_url}"
  end
  park = Park.new(:name => park_name, :id => park_id)
  
  found_park = parks.find{|p| p.name == park.name}
  if found_park
    # Double-check that the url is the same
    raise "Oops. Multiple parks with the same name" unless found_park == park
    park = found_park
  end
  
  url = (page.uri + URI.parse(camp.search('td')[0].at('a').attributes['href'])).to_s
  if url =~ /^http:\/\/www\.environment\.nsw\.gov\.au\/NationalParks\/parkCamping\.aspx\?id=(\w+)#(\w+)$/
    raise "park id does not match" unless $~[1] == park.id
    camp_id = $~[2]
  else
    raise "Unexpected form for url: #{url}"
  end
  
  c = CampSite.new(
    :name => camp.search('td')[0].inner_text.strip,
    :id => camp_id,
    :park => park
    )
    
  alt_attributes = camp.search('td')[2].search('img').map{|i| i.attributes['alt'].to_s.downcase}
  if alt_attributes.empty?
    description = camp.search('td')[2].inner_text.strip.downcase
    case description
    when "long walk from car to tent"
      c.length_walk = :long
      c.caravans = false
      c.trailers = false
      c.car = false
    when "short walk from car to tent"
      c.length_walk = :short
      c.caravans = false
      c.trailers = false
      c.car = false
    else
      raise "Unexpected text: #{description}"
    end
  else
    c.length_walk = :none
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
      c.toilets = :non_flush
    when "flush toilets"
      c.toilets = :flush
    when "no toilets"
      c.toilets = false
    when "no picnic tables"
      c.picnic_tables = false
    when "picnic tables"
      c.picnic_tables = true
    when "no barbecues"
      c.barbecues = false
    when "wood barbecues", 
      c.barbecues = :wood
    when "wood barbecues (firewood supplied)"
      c.barbecues = :wood_supplied
    # Not recording that the BBQs are free
    when "gas/electric barbecues", "gas/electric barbecues (free)"
      c.barbecues = :gas_electric
    when "wood barbecues (bring your own firewood)"
      c.barbecues = :wood_bring_your_own
    when "no showers"
      c.showers = false
    when "hot showers"
      c.showers = :hot
    when "cold showers"
      c.showers = :cold
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

campsites.each do |c|
  puts c.pretty_print
end