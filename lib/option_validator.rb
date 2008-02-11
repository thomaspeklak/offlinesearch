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

    unless(language.include?($config['language']))
      puts 'storage must be memory or sqlite'
      exit
    end
    unless(storage.include?($config['storage']))
      puts 'storage must be memory or sqlite'
      exit
    end
    unless($config['crawler']['docs'].size>0)
      puts 'doc types must be specified'
      exit
    end
    unless (File.exists?($config['crawler']['stopwords']))
      puts 'stopwords file does not exist'
      exit
    end
  end
end