#
# * $Author$
# * $Rev$
# * $LastChangedDate$
#

require "YAML"
require "crawler"

$config = YAML.load_file("config.yaml")

crawler=Crawler.new

crawler.find_files
crawler.parse_files
crawler.get_stored_files
