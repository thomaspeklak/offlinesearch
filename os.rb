/*
 * $Author$
 * $Rev$
 * $LastChangedDate$
 */

require "YAML"
require "crawler"

$config = YAML.load(File.open("config.yaml"))

crawler=Crawler.new

crawler.find_files
crawler.parse_files
crawler.get_stored_files