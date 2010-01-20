$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'utils'

describe "html_into_plain_text" do
  it "should turn paragraph blocks into plain text separated by carriage returns" do
    html_into_plain_text("<div><p>One.</p><p>And another.</p></div>").should == "One.\n\nAnd another."
  end
  
  it "should remove link tags" do
    html_into_plain_text("<div><p>It should just <a>ignore and remove</a> links.</p></div>").should == "It should just ignore and remove links."
  end
end