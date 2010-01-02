require 'rubygems'
require 'mechanize'
require 'simple_struct'

class CampSite < SimpleStruct
  add_attributes :name, :url, :type, :park_name, :park_url,
    :toilets, :flush_toilets, :picnic_tables, :barbecues, :wood_barbecues, :bring_firewood, :gas_electric_barbecues,
    :showers, :hot_showers, :drinking_water
end

agent = WWW::Mechanize.new
page = agent.get("http://www.environment.nsw.gov.au/NationalParks/SearchCampgrounds.aspx")
page = page.form_with(:name => "campgroundsSearch").submit
page.search('#SearchResults')[1].search('tr')[1..-1].each do |camp|
  c = CampSite.new(
    :name => camp.search('td')[0].inner_text.strip,
    :url => page.uri + URI.parse(camp.search('td')[0].at('a').attributes['href']),
    :type => camp.search('td')[2].inner_text.strip,
    :park_name => camp.search('td')[3].inner_text.strip,
    :park_url => page.uri + URI.parse(camp.search('td')[3].at('a').attributes['href'])
    )

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
  p c
  puts "****"
end