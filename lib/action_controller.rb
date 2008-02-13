# 
#
# * $Author: tom $
# * $Rev: 100 $
# * $LastChangedDate: 2008-02-11 18:21:07 +0100 (Mon, 11 Feb 2008) $
#

class ActionController
  def initialize()
    case $action
    when 'generate_default_stopwords'
      generate_stopwords
    when 'generate_default_config'
      generate_config
    when 'generate_template'
      generate_template
    when 'generate_search'
      verify_search_parameters
      start_search
    end
  end
  
  private
  def generate_stopwords
		$logger.info("generating default stopwords")
    require 'generate_default_stopwords'
  end
  def generate_config
		$logger.info("generating default config")
    require 'generate_default_config'
  end
  def generate_template
		$logger.info("generating default template")
    require 'generate_default_template'
    TemplateGenerator.new('base')
  end
  def verify_search_parameters
    require 'option_validator'
    OptionValidator.new
  end
  def start_search
    require "log_init"
    require "stop_words"
    require "crawler"
    require "search_generator"

    crawler = Crawler.new
    crawler.find_files
    crawler.parse_files

    generator = SearchGenerator.new(crawler.get_stored_files, crawler.get_terms)
    generator.generate
  end
end