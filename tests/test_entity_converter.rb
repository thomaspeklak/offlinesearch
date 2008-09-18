$: << File.expand_path(File.dirname(__FILE__)+'/../lib')

require 'test/unit' 
require 'entity_converter'

class TestEntityConverter < Test::Unit::TestCase 

  def test_decode_html_entities
    assert_equal 'äöüÄÖÜß',"&auml;&ouml;&uuml;&Auml;&Ouml;&Uuml;&szlig;".decode_html_entities
  end
    
  def test_encode_html_entities
    assert_equal "&auml;&ouml;&uuml;&Auml;&Ouml;&Uuml;&szlig;", "äöüÄÖÜß".encode_html_entities
  end
  
  def test_entity_to_downcase
    assert_equal 'äöüäöüß', 'äöüÄÖÜß'.html_entity_downcase
  end
end
