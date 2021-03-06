# checks if all required arguments are specified and if their values are correct
#
# * $Author$
# * $Rev$
# * $LastChangedDate$
#
require 'rubygems'
require 'fancylog'

class OptionValidator
  def initialize
    @l = FancyLog.instance
    storage = ['memory','sqlite']
    language = ['german','english']

    if ($config['crawler']['stopwords'].nil?) then
      $config['crawler']['stopwords'] = File.dirname(__FILE__) +"/stoplist/#{$config['language']}/stopwords.txt"
    end

    unless(language.include?($config['language']))
      @l.error('language must be english or german')
      exit
    end
    unless(storage.include?($config['storage']))
      @l.error('storage must be memory or sqlite')
      exit
    end
    unless($config['crawler']['docs'] && $config['crawler']['docs'].size>0)
      @l.error('doc types must be specified')
      exit
    end
    unless (File.exists?($config['crawler']['stopwords']))
      @l.error('stopwords file does not exist')
      exit
    end
    unless ($config['crawler'].has_key?('max_semantic_depth'))
      $config['crawler']['max_semantic_depth'] = 3
    end
    
    unless (directory_exists?($config['crawler']['docpath']))
      @l.error('docpath does not exist')
    end
    
    unless (base_directory_exists?($config['search_generator']['search_data_file']))
      @l.error('path to the search data file does not exits. Please create the directory first')
    end
    
    unless (base_directory_exists?($config['search_generator']['output_frequency_to']))
      @l.error('path to the frequency file does not exits. Please create the directory first')
    end
  end
  
  private
  def base_directory_exists?(file)
    FileTest.directory?(File.dirname(file))
  end 
  def directory_exists?(dir)
    FileTest.directory?(dir)
  end 
end