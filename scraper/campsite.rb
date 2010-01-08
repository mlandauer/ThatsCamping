require 'rubygems'
require 'activerecord'

class Campsite < ActiveRecord::Base
  has_one :park

  def url
    "#{park.campsites_url}##{web_id}"
  end
end
