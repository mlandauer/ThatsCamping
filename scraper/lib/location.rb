require 'rubygems'
require 'active_record'
require 'source'

class Location < ActiveRecord::Base
  belongs_to :source
end

