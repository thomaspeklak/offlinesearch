Gem::Specification.new do |s| 
  s.name = "OfflineSearch" 
  s.version = "0.2.2" 
  s.author = "Thomas Peklak" 
  s.email = "thomas.peklak@gmail.com" 
  s.platform = Gem::Platform::RUBY 
  s.summary = "A semantic offline search" 
  s.require_path = "lib"
  s.files =  ["bin/OfflineSearch", "lib/action_controller.rb", "lib/config.yaml", "lib/config_default.yaml", "lib/crawler.rb", "lib/entity_converter.rb", "lib/generate_default_config.rb", "lib/generate_default_stopwords.rb", "lib/generate_default_template.rb", "lib/log_init.rb", "lib/offline_search.rb", "lib/option_parser.rb", "lib/option_validator.rb", "lib/search_generator.rb", "lib/stop_words.rb", "lib/stoplist", "lib/stoplist/english", "lib/stoplist/english/stopwords.txt", "lib/stoplist/german", "lib/stoplist/german/stopwords.txt", "lib/temporary_storage.rb", "templates/base", "templates/base/jquery-1.2.2.min.js", "templates/base/search.css", "templates/base/search.html", "templates/base/search.js", "templates/base+double_metaphone", "templates/base+double_metaphone/jquery-1.2.2.min.js", "templates/base+double_metaphone/jQueryDoubleMetaphone.js", "templates/base+double_metaphone/jQueryDoubleMetaphone.packed.js", "templates/base+double_metaphone/search.css", "templates/base+double_metaphone/search.html", "templates/base+double_metaphone/search.js"]
  s.test_file = "tests/notestsyet.rb" 
  s.has_rdoc = true 
  s.add_dependency("hpricot", ">= 0.6")
  s.add_dependency("Text", ">= 1.1.2")
  s.add_dependency("filefinder", ">= 0.0.4")
  s.add_dependency("progressbar", ">= 0.0.3")
  s.bindir = 'bin'
  s.executable = 'OfflineSearch'
  s.extra_rdoc_files = ["README"] 
  s.rdoc_options = %w{--main README}
end