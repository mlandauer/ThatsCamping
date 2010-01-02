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
  add_attributes :id, :name, :park,
    :toilets, :flush_toilets, :picnic_tables, :barbecues, :wood_barbecues, :bring_firewood, :gas_electric_barbecues,
    :showers, :hot_showers, :drinking_water
  # A long walk or short walk from the car to the camp site?
  add_attributes :long_walk, :short_walk
  # Suitable for caravans or trailers or car camping?
  add_attributes :caravans, :trailers, :car
  
  def url
    "http://www.environment.nsw.gov.au/NationalParks/parkCamping.aspx?id=#{park.id}##{id}"
  end
  
  def pretty_print
    facilities = []
    if flush_toilets
      facilities << "Flush toilets"
    elsif toilets
      facilities << "Non-flush toilets"
    else
      facilities << "No toilets"
    end
    facilities << (picnic_tables ? "Picnic tables" : "No picnic tables")
    if gas_electric_barbecues
      facilities << "Gas/Electric barbecues"
    elsif wood_barbecues && bring_firewood
      facilities << "Wood barbecues (bring your own firewood)"
    elsif wood_barbecues
      facilities << "Wood barbecues (firewood provided)"
    else
      facilities << "No barbecues"
    end
    if hot_showers
      facilities << "Hot showers"
    elsif showers
      facilities << "Showers"
    else
      facilities << "No showers"
    end
    facilities << (drinking_water ? "Drinking water" : "No drinking water")
    access = []
    access << (caravans ? "Caravan camping" : "No caravan camping")
    access << (trailers ? "Trailer camping" : "No trailer camping")
    access << (car ? "Car camping" : "No car camping")
    if long_walk
      access << "Long walk from car to camp site"
    elsif short_walk
      access << "Short walk from car to camp site"
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

campsites.each do |c|
  puts c.pretty_print
end