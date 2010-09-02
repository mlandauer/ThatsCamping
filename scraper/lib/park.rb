require 'rubygems'
require 'active_record'
require 'campsite'

class Park < ActiveRecord::Base
  has_many :campsites
  
  def url
    "http://www.environment.nsw.gov.au/NationalParks/parkHome.aspx?id=#{web_id}"
  end
  
  def campsites_url
    "http://www.environment.nsw.gov.au/NationalParks/parkCamping.aspx?id=#{web_id}"
  end
end

