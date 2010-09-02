require 'rubygems'
require 'active_record'

class Campsite < ActiveRecord::Base
  belongs_to :park

  def url
    "#{park.campsites_url}##{web_id}"
  end
end
