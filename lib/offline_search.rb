# Start point for OS
#
# * $Author$
# * $Rev$
# * $LastChangedDate$
#

require 'option_parser'
require 'option_validator'
OptionValidator.new

require "log_init"

require "stop_words"



require "crawler"
require "search_generator"

crawler = Crawler.new

crawler.find_files
crawler.parse_files

generator = SearchGenerator.new(crawler.get_stored_files, crawler.get_terms)
generator.generate
