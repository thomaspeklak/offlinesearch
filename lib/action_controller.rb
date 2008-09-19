# ACTION CONTROLLER
# checks which option is specified and executes the required scripts
#
# * $Author$
# * $Rev$
# * $LastChangedDate$
#
require 'rubygems'
require 'fancylog'

class ActionController
  # checks the value of the global variable $action set by option parser
  # valid actions are
  # * genrating a default stopwords
  # * genrating a default config file
  # * genrating a template
  # * genrating the search database
  def initialize()
    setup_logger
    unless defined?($action)
      @l.fatal("No action is defined. Please chose one of the following options:\n\t\t-o generate search index\n\t\t-t generate template files\n\t\t-o generate default stop words\n\t\t-g generate default config")
      exit
    end
    case $action
    when 'generate_default_stopwords'
      generate_stopwords
    when 'generate_default_config'
      generate_config
    when 'generate_template'
			unless (['base','base+double_metaphone'].include?($config['template']))
				@l.error('Template not found')
				@l.info('Available templates: base,base+double_metaphone')
				exit
			end
      generate_template
    when 'generate_search'
      verify_search_parameters
      start_search
    end
  end
  
  private
  def generate_stopwords
		@l.info("generating default stopwords")
    require 'generate_default_stopwords'
  end
  def generate_config
		@l.info("generating default config")
    require 'generate_default_config'
  end
  def generate_template
		@l.info("generating default template")
    require 'generate_default_template'
    TemplateGenerator.new($config['template'])
  end
  def verify_search_parameters
    require 'option_validator'
    OptionValidator.new
  end
  def start_search
    require "stop_words"
    require "crawler"
    require "search_generator"

    crawler = Crawler.new
    crawler.find_files
    crawler.parse_files

    generator = SearchGenerator.new(crawler.get_stored_files, crawler.get_terms)
    generator.generate
  end
  
  private
  def setup_logger
    out_level = eval("Logger::#{$config['logger']['level'].upcase}")
    out_device = ($config['logger']['file'] == 'STDOUT')? STDOUT : $config['logger']['file']
    @l = FancyLog.setup(:out_level => out_level, :out_device => out_device).instance, :default_level => 'info')
  end
end