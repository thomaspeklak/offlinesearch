# generates the default stopword list in the current directory
# the language is taken from the language switch
#
# * $Author$
# * $Rev$
# * $LastChangedDate$
#
require 'fileutils'
include FileUtils

language = ['german','english']
unless(defined?($config) && language.include?($config['language']))
  $logger.error('language must be english or german')
  exit
end


cp(File.dirname(__FILE__) +"/stoplist/#{$config['language']}/stopwords.txt",'./')