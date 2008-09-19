$: << File.expand_path(File.dirname(__FILE__)+'/../lib')


require 'test/unit' 
require 'option_validator'

class TestOptionValidator < Test::Unit::TestCase 
  def setup
    $config = {'logger'=> { 'file' => STDOUT, 'level' => 'INFO'}}
    require 'yaml'
    $config = YAML.load_file(File.expand_path(File.dirname(__FILE__)+'/../tests/test_files/ov_config.yaml'))
  end
  def test_standard
    OptionValidator.new()
  end
end
