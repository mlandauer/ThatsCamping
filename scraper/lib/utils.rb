# Random bits and bobs

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
  a.children.each do |c|
    c.parent = a.parent
  end
  a.remove
end

# Needs to be of the form: "<div><p>foo</p><p>Hello</p></div>" which will become "foo\n\nHello"
def html_into_plain_text(html)
  description = Nokogiri::HTML.fragment(html)
  # Remove images and links associated with them
  description.search('a > img').each{|i| i.parent.remove}
  description.search('img').remove
  description.search('div#footer').remove
  description.search('div.clearRight').remove
  description.search('script').remove
  # Turn occurences of "<a>foo</a>" into "foo"
  description.search('a').each {|a| replace_with_inside(a)}
  description.search('b').each {|a| replace_with_inside(a)}
  description.search('font').each {|a| replace_with_inside(a)}
  description.search('span').each {|a| replace_with_inside(a)}
  description.search('ul').each {|a| replace_with_inside(a)}
  description.search('li').each {|a| replace_with_inside(a)}
  description.search('div > div').each {|a| replace_with_inside(a)}
  
  # Turn all occurences of "<p>Some Text</p>" into "Some Text<br>"
  description.search('p').each do |p|
    p.children.each do |c|
      c.parent = p.parent
    end
    br = Nokogiri::XML::Node.new "br", description
    br.parent = p.parent
    p.remove
  end
  description = description.at('div').inner_html
  # replace &nbsp; with a simple space
  description.gsub!("&nbsp;", " ")
  # Now replace "<br>" by "\n\n"
  description = simplify_whitespace(description)
  description.gsub!("<br>", "\n")
  description.squeeze!("\n")
  description.gsub!("\n", "\n\n")
  description = description.strip
  # Remove comments
  description.gsub!(/<!--.*-->/, "")
  description
end
