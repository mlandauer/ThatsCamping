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

