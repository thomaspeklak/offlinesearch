# extends the string class to convert html entities

class String
  #methods for converting entities
  def self.html_entities
    @@html_entities
  end
  
  @@html_entities = {
    'À' => ['&Agrave;', '&#192;', 'à'],
    'Á' => ['&Aacute;', '&#193;', 'á'],
    'Â' => ['&Acirc;', '&#194;', 'â'],
    'Ã' => ['&Atilde;', '&#195;', 'ã'],
    'Ä' => ['&Auml;', '&#196;', 'ä'],
    'Å' => ['&Aring;', '&#197;', 'å'],
    'Æ' => ['&AElig;', '&#198;', 'æ'],
    'Ç' => ['&Ccedil;', '&#199;', 'ç'],
    'È' => ['&Egrave;', '&#200;', 'è'],
    'É' => ['&Eacute;', '&#201;', 'é'],
    'Ê' => ['&Ecirc;', '&#202;', 'ê'],
    'Ë' => ['&Euml;', '&#203;', 'ë'],
    'Ì' => ['&Igrave;', '&#204;', 'ì'],
    'Í' => ['&Iacute;', '&#205;', 'í'],
    'Î' => ['&Icirc;', '&#206;', 'î'],
    'Ï' => ['&Iuml;', '&#207;', 'ï'],
    'Ð' => ['&ETH;', '&#208;', 'ð'],
    'Ñ' => ['&Ntilde;', '&#209;', 'ñ'],
    'Ò' => ['&Ograve;', '&#210;', 'ò'],
    'Ó' => ['&Oacute;', '&#211;', 'ó'],
    'Ô' => ['&Ocirc;', '&#212;', 'ô'],
    'Õ' => ['&Otilde;', '&#213;', 'õ'],
    'Ö' => ['&Ouml;', '&#214;', 'ö'],
    'Ø' => ['&Oslash;', '&#216;', 'ø'],
    'Ù' => ['&Ugrave;', '&#217;', 'ù'],
    'Ú' => ['&Uacute;', '&#218;', 'ú'],
    'Û' => ['&Ucirc;', '&#219;', 'û'],
    'Ü' => ['&Uuml;', '&#220;', 'ü'],
    'Ý' => ['&Yacute;', '&#221;', 'ý'],
    'Þ' => ['&THORN;', '&#222;', 'þ'],
    'ß' => ['&szlig;', '&#223;'],
    'à' => ['&agrave;', '&#224;'],
    'á' => ['&aacute;', '&#225;'],
    'â' => ['&acirc;', '&#226;'],
    'ã' => ['&atilde;', '&#227;'],
    'ä' => ['&auml;', '&#228;'],
    'å' => ['&aring;', '&#229;'],
    'æ' => ['&aelig;', '&#230;'],
    'ç' => ['&ccedil;', '&#231;'],
    'è' => ['&egrave;', '&#232;'],
    'é' => ['&eacute;', '&#233;'],
    'ê' => ['&ecirc;', '&#234;'],
    'ë' => ['&euml;', '&#235;'],
    'ì' => ['&igrave;', '&#236;'],
    'í' => ['&iacute;', '&#237;'],
    'î' => ['&icirc;', '&#238;'],
    'ï' => ['&iuml;', '&#239;'],
    'ð' => ['&eth;', '&#240;'],
    'ñ' => ['&ntilde;', '&#241;'],
    'ò' => ['&ograve;', '&#242;'],
    'ó' => ['&oacute;', '&#243;'],
    'ô' => ['&ocirc;', '&#244;'],
    'õ' => ['&otilde;', '&#245;'],
    'ö' => ['&ouml;', '&#246;'],
    'ø' => ['&oslash;', '&#248;'],
    'ù' => ['&ugrave;', '&#249;'],
    'ú' => ['&uacute;', '&#250;'],
    'û' => ['&ucirc;', '&#251;'],
    'ü' => ['&uuml;', '&#252;'],
    'ý' => ['&yacute;', '&#253;'],
    'þ' => ['&thorn;', '&#254;'],
    'ÿ' => ['&yuml;', '&#255;'],
    '§' => ['&sect;','&#167;']
  }
  
  { :encode_html_entities => @@html_entities.inject([]) {|a, x| a << [/#{x[0]}/, x[1][0]] << [/#{x[0]}/, x[1][1]] },
    :decode_html_entities => @@html_entities.inject([]) {|a, x| a << [/#{x[1][0]}/, x[0]] << [/#{x[1][1]}/, x[0]] },
    :html_entity_downcase => @@html_entities.select{|k,v| v.length==3 }.inject([]) {|a,x| a << [/#{x[0]}/, x[1][2]] }
  }.each do |meth, key_value_pairs|
      translate = Regexp.union(*key_value_pairs.collect { |k,v| k })
      define_method(meth) {
        gsub(translate) do |match|
          key_value_pairs.detect{|k,v| k =~ match}[1]
        end
      }
    end
end