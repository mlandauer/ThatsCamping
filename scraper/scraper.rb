require 'rubygems'
require 'mechanize'

agent = WWW::Mechanize.new
page = agent.get("http://www.environment.nsw.gov.au/NationalParks/SearchCampgrounds.aspx")
page = page.form_with(:name => "campgroundsSearch").submit
page.search('#SearchResults')[1].search('tr')[1..-1].each do |camp|
  name = camp.search('td')[0].inner_text.strip
  puts "Name: #{name}"
  url = page.uri + URI.parse(camp.search('td')[0].at('a').attributes['href'])
  puts "URL: #{url}"
  toilets, flush_toilets, picnic_tables, barbecues, wood_barbecues, bring_firewood, gas_electric_barbecues, showers, hot_showers, drinking_water = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
  camp.search('td')[1].search('img').map{|i| i.attributes['alt'].to_s.downcase}.each do |text|
    case text
    when "non-flush toilets"
      toilets = true
      flush_toilets = false
    when "flush toilets"
      toilets = true
      flush_toilets = true
    when "no toilets"
      toilets = false
      flush_toilets = false
    when "no picnic tables"
      picnic_tables = false
    when "picnic tables"
      picnic_tables = true
    when "no barbecues"
      barbecues = false
      wood_barbecues = false
      gas_electric_barbecues = false
    when "wood barbecues"
      barbecues = true
      wood_barbecues = true
      gas_electric_barbecues = false
    when "gas/electric barbecues"
      barbecues = true
      wood_barbecues = false
      gas_electric_barbecues = true
    # Not recording that the BBQs are free
    when "gas/electric barbecues (free)"
      barbecues = true
      wood_barbecues = false
      gas_electric_barbecues = true      
    when "wood barbecues (bring your own firewood)"
      barbecues = true
      wood_barbecues = true
      bring_firewood = true
    when "wood barbecues (firewood supplied)"
      barbecues = true
      wood_barbecues = true
      bring_firewood = false      
    when "no showers"
      showers = false
      hot_showers = false
    when "hot showers"
      showers = true
      hot_showers = true
    when "cold showers"
      showers = true
      hot_showers = false
    when "no drinking water"
      drinking_water = false
    when "drinking water"
      drinking_water = true
    else
      raise "Unexpected text description: #{text}"
    end
  end
  puts "Toilets: #{toilets}"
  puts "Flush toilets: #{flush_toilets}"
  puts "Picnic tables: #{picnic_tables}"
  puts "Barbecues: #{barbecues}"
  puts "Wood barbecues: #{wood_barbecues}"
  puts "Bring your own firewood: #{bring_firewood}"
  puts "Gas/Electric barbecues: #{gas_electric_barbecues}"
  puts "Showers: #{showers}"
  puts "Hot showers: #{hot_showers}"
  puts "Drinking water: #{drinking_water}"
  type = camp.search('td')[2].inner_text.strip
  puts "Type of camping: #{type}"
  park_name = camp.search('td')[3].inner_text.strip
  puts "Park name: #{park_name}"
  park_url = page.uri + URI.parse(camp.search('td')[3].at('a').attributes['href'])
  puts "Park URL: #{park_url}"
  puts "****"
end