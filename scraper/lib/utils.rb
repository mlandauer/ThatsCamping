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
