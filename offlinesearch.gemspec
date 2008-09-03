Gem::Specification.new do |s| 
  s.name = "OfflineSearch" 
  s.version = "0.2.2" 
  s.author = "Thomas Peklak" 
  s.email = "thomas.peklak@gmail.com" 
  s.platform = Gem::Platform::RUBY 
  s.summary = "A semantic offline search" 
  s.require_path = "lib"
  s.files = Dir["{bin,docs,lib,conf,templates}/**/*"]
  s.test_file = "tests/notestsyet.rb" 
  s.has_rdoc = true 
  s.add_dependency("hpricot", ">= 0.6")
  s.add_dependency("Text", ">= 1.1.2")
  s.add_dependency("filefinder", ">= 0.0.4")
  s.add_dependency("progressbar", ">= 0.0.3")
  s.bindir = 'bin'
  s.executable = 'OfflineSearch'
  s.extra_rdoc_files = ["README"] 
end