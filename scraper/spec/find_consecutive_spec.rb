$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'find_consecutive'

describe Enumerable, "find_consecutive" do
  it "should find all consecutive elements that match a condition" do
    a = [1, 2, 3, 4, 1, 2, 3, 4]
    a.find_consecutive{|n| n > 2}.should == [3, 4]
  end
end