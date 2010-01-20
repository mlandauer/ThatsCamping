# Random bits and bobs

require 'rubygems'
require 'nokogiri'

def prepare_source(name, url)
  source = Source.find(:first, :conditions => {:name => name})
  if source
    # Zap all the old data
    Location.delete_all(:source_id => source.id)
  else
    source = Source.new(:name => name, :url => url)
    source.save!
  end
  source
end

def convert_degrees_mins(degrees, minutes, seconds)
  offset = (minutes + seconds / 60.0) / 60.0
  if degrees < 0
    degrees - offset
  else
    degrees + offset
  end
end

# Remove any of the given special phrases from the end of the given name
def remove_phrases_at_end(name, special_phrases)
  substitute_phrases_at_end(name, special_phrases.map{|p| [p, ""]})
end

def substitute_phrases_at_end(name, special_phrases)
  shorter = name
  special_phrases.each do |phrase, substitute|
    shorter = shorter.sub(Regexp.new("\\b#{phrase}$", true), substitute)
  end
  shorter.strip
end

def simplify_whitespace(str)
  str.gsub(/[\n\t\r]/, " ").squeeze(" ").strip
end

def replace_with_inside(a)
  insert_point = a
  a.children.each do |c|
    insert_point.add_next_sibling(c)
    insert_point = c
  end
  a.remove
end

# Needs to be of the form: "<div><p>foo</p><p>Hello</p></div>" which will become "foo\n\nHello"
def html_into_plain_text(html)
  description = Nokogiri::HTML.fragment(html)
  # Remove images and links associated with them
  description.search('a > img').each{|i| i.parent.remove}
  ['img', 'div#footer', 'div.clearRight', 'script', 'h3', 'link'].each do |s|
    description.search(s).remove
  end
  # Turn occurences of "<a>foo</a>" into "foo"
  ['a', 'b', 'i', 'font', 'span', 'ul', 'li', 'div > div'].each do |s|
    description.search(s).each {|a| replace_with_inside(a)}
  end
  
  # Turn all occurences of "<p>Some Text</p>" into "Some Text<br>"
  description.search('p').each do |p|
    insert_point = p
    p.children.each do |c|
      insert_point.add_next_sibling(c)
      insert_point = c
    end
    br = Nokogiri::XML::Node.new "br", description
    insert_point.add_next_sibling(br)
    p.remove
  end
  description = description.at('div').inner_html
  # replace &nbsp; with a simple space
  description.gsub!("&nbsp;", " ")
  description.gsub!("&ndash;", "-")
  # Now replace "<br>" by "\n\n"
  description = simplify_whitespace(description)
  description.gsub!("<br>", "\n")
  description.gsub!(/\n\s+/, "\n")
  description.squeeze!("\n")
  description.gsub!("\n", "\n\n")
  description = description.strip
  # Remove comments
  description.gsub!(/<!--.*-->/, "")
  
  # Remove all paragraphs with the word 'pdf' in them (because they're just links to maps)
  # Don't match full stops with pdf after them or full stops in the middle of numbers
  # This little bit here is a bounty of ugliness. Don't ask me to explain how it works. I can't remember.
  # And I wrote it three minutes ago...
  description.gsub!(".pdf", "pdf")
  description.gsub!(/(\d)\.(\d)/, '\1axax\2')
  description = description.split("\n\n").map do |s1|
    temp = s1.split(".").reject{|t| t =~ /pdf/i}.join(".")
    temp += "." if s1[-1..-1] == "." && temp != ""
    temp if temp != ""
  end.compact.join("\n\n")
  description.gsub!("axax", ".")
  
  description
end
