#
# * $Author$
# * $Rev$
# * $LastChangedDate$
#

require "YAML"
$config = YAML.load_file("config.yaml")

require "log_init"

require "crawler"

crawler=Crawler.new

crawler.find_files
crawler.parse_files
crawler.get_stored_files
