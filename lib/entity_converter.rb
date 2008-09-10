# extends the string class to convert html entities
# use carefully, can not convert entities back, as some entities are just skipped, because the are not useful for the search generation process
#
# * $Author$
# * $Rev$
# * $LastChangedDate$

class String
  # this method converts encoded entities to their utf-8 euqivalent. be careful this method strips out all unknown entities because they are of no special use for the semantic search
  def decode_html_entities
    mgsub([[/&auml;/,'ä'],[/&Auml;/,'Ä'],[/&ouml;/,'ö'],[/&Ouml;/,'Ö'],[/&uuml;/,'ü'],[/&Uuml;/,'Ü'],[/&szlig;/,'ß'],[/&[a-zA-Z]{4,6};/,' ']])
  end

  # encodes html entities
  def encode_html_entities
    mgsub([[/ä/,'&auml;'],[/Ä/,'&Auml;'],[/ö/,'&ouml;'],[/Ö/,'&Ouml;'],[/ü/,'&uuml;'],[/Ü/,'&Uuml;'],[/ß/,'&szlig;']])    
  end
  
  # converts uppercase umlauts to downcase
  def umlaut_to_downcase
    mgsub([[/Ä/,'ä'],[/Ö/,'ö'],[/Ü/,'ü']])
  end
  
  private

  # method to substitute multiple strings at once. [Author: Ruby Cookbook]
  def mgsub(key_value_pairs=[].freeze)
    regexp_fragments = key_value_pairs.collect { |k,v| k }
    gsub(Regexp.union(*regexp_fragments)) do |match|
    key_value_pairs.detect{|k,v| k =~ match}[1]
  end
end  
end