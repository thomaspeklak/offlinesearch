# extends the string class to convert html entities
# use carefully, can not convert entities back, as some entities are just skipped, because the are not useful for the search generation process
#
# * $Author$
# * $Rev$
# * $LastChangedDate$

class String
  #methods for converting entities
  { :decode_html_entities    => [[/&auml;/,'ä'],[/&Auml;/,'Ä'],[/&ouml;/,'ö'],[/&Ouml;/,'Ö'],[/&uuml;/,'ü'],[/&Uuml;/,'Ü'],[/&szlig;/,'ß'],[/&[a-zA-Z]{4,6};/,' ']],
    :encode_html_entities  => [[/ä/,'&auml;'],[/Ä/,'&Auml;'],[/ö/,'&ouml;'],[/Ö/,'&Ouml;'],[/ü/,'&uuml;'],[/Ü/,'&Uuml;'],[/ß/,'&szlig;']],
    :umlaut_to_downcase    => [[/Ä/,'ä'],[/Ö/,'ö'],[/Ü/,'ü']] }.each do |meth, key_value_pairs|
      translate = Regexp.union(*key_value_pairs.collect { |k,v| k })
      define_method(meth) {
        gsub(translate) do |match|
          key_value_pairs.detect{|k,v| k =~ match}[1]
        end
      }
    end
end