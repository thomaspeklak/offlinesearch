# checks if all required arguments are specified and if their values are correct
#
# * $Author$
# * $Rev$
# * $LastChangedDate$
#
class OptionValidator
  def initialize
    storage = ['memory','sqlite']
    language = ['german','english']

    if ($config['crawler']['stopwords'].nil?) then
      $config['crawler']['stopwords'] = File.dirname(__FILE__) +"/stoplist/#{$config['language']}/stopwords.txt"
    end

    unless(language.include?($config['language']))
      $logger.error('language must be english or german')
      exit
    end
    unless(storage.include?($config['storage']))
      $logger.error('storage must be memory or sqlite')
      exit
    end
    unless($config['crawler']['docs'].size>0)
      $logger.error('doc types must be specified')
      exit
    end
    unless (File.exists?($config['crawler']['stopwords']))
      $logger.error('stopwords file does not exist')
      exit
    end
    
    unless (directory_exists?($config['crawler']['docpath']))
      $logger.error('docpath does not exist')
    end
    
    unless (base_directory_exists?($config['search_generator']['search_data_file']))
      $logger.error('path to the search data file does not exits. Please create the directory first')
    end
    
    unless (base_directory_exists?($config['search_generator']['output_frequency_to']))
      $logger.error('path to the frequency file does not exits. Please create the directory first')
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