$: << File.expand_path(File.dirname(__FILE__)+'/../lib')
require "test/unit"

class TestStopwords < Test::Unit::TestCase
  def test_load_stopwords
    file = File.expand_path(File.dirname(__FILE__)+'/../tests/test_files/stopwords.txt')
    $config = {'crawler' => {'stopwords' => file}}
    require "stop_words.rb"
    assert_equal 317, $stop_words.length
    w = File.read(file).split(/[\r\n]+/)
    w.map{|l| l.chomp}
    assert_equal w.sort, $stop_words.keys.sort
    assert $stop_words.values.all? { |v| v.nil? }
  end
end