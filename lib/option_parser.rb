#parses command line options and merges them into the config file
#
# * $Author$
# * $Rev$
# * $LastChangedDate$
#
require "YAML"

require 'optparse'
$config = Hash.new
OptionParser.new do |opts|
  opts.banner = "Usage: OfflineSearch [options]"
  opts.on('-c', '--config=CONFIG_FILE', String,'configuration file for the offline search') do |c|
    if (File.exists?(c))
      $config = YAML.load_file(c)
      $action = 'generate_search'
    else
      puts 'config file not found'
      exit      
    end
  end
  opts.separator ""
  opts.separator "Optional arguments"
  opts.separator "can also be specified in the config file"
  opts.separator "command line arguments will overwrite any given value in the config file"
  opts.on('-d', '--docpath=DOCPATH', String,'path of the documents') do |d|
    $config['crawler']['docpath'] = d
  end 
  opts.on('-f', '--search-data-file=SEARCH_DATA_FILE', String,'path and name of the search data file') do |f|
    $config['search_generator']['search_data_file'] = f
  end
  opts.on('-s', '--stopword-list=STOPWORD_LIST', String,'stopword list, if none is specified the default stop word list is used') do |s|
    $config['crawler']['stopwords'] = s
  end
  opts.on('-l','--language=LANGUAGE',String,'required if you want to generate a default stopword list') do |l|
    $config['language'] = l
  end  
  opts.separator ""
  opts.separator "Generators"
  opts.on('-g','--generate-default-config') do
    $action = 'generate_default_config'
  end
  opts.on('-w','--generate-default-stopwords') do
    $action = 'generate_default_stopwords'
  end
  opts.on('-t','--generate-template') do
    $action = 'generate_template'
  end
  opts.separator ""
  opts.on_tail('-h','--help','Show this message') do
    puts opts
    exit
  end
  if (opts.default_argv.size == 0)
    puts opts
    exit
  end
end.parse!