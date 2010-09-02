require 'rubygems'
require 'active_record'

# Establish the connection to the database
ActiveRecord::Base.establish_connection(
        :adapter  => "sqlite3",
        :database => File.join(File.dirname(__FILE__), "..", "data", "thatscampin.db")
)

