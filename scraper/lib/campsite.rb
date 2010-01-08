require 'rubygems'
require 'activerecord'

class Campsite < ActiveRecord::Base
  belongs_to :park

  def url
    "#{park.campsites_url}##{web_id}"
  end
end
