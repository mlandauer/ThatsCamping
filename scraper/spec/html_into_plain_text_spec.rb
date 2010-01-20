$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'utils'

describe "html_into_plain_text" do
  it "should turn paragraph blocks into plain text separated by carriage returns" do
    html_into_plain_text("<div><p>One.</p><p>And another.</p></div>").should == "One.\n\nAnd another."
  end
  
  it "should remove link tags" do
    html_into_plain_text("<div><p>It should just <a>ignore and remove</a> links.</p></div>").should == "It should just ignore and remove links."
  end
  
  it "should replace ndashes" do
    html_into_plain_text("<div><p>Hello &ndash; there</p></div>").should == "Hello - there"
  end
  
  it "should get rid of italics" do
    html_into_plain_text("<div><p><i>Hello</i> there</p></div>").should == "Hello there"
  end
  
  it "should not reorder elements" do
    html_into_plain_text("<div><p>A</p><h2>B</h2><p>C</p></div>").should == "A\n\n<h2>B</h2>C"
  end 
  
  it "should delete h3 tags" do
    html_into_plain_text("<div><h3>A</h3></div>").should == ""
  end
  
  it "should not leave a dangling space at the beginning of a paragraph" do
    html_into_plain_text("<div><p>One</p>  <p>And another</p></div>").should == "One\n\nAnd another"
  end
  
  it "should remove a random <link> tag" do
    #html_into_plain_text("<div><p></p></div>").should == ""
    html_into_plain_text("<div><p>A <link> link should be ignored</p></div>").should == "A link should be ignored"
  end
end