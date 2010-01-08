require 'rubygems'
require 'activerecord'
require 'source'

class Location < ActiveRecord::Base
  belongs_to :source
end

