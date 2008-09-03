Gem::Specification.new do |s| 
  s.name = "OfflineSearch" 
  s.version = "0.2.2" 
  s.author = "Thomas Peklak" 
  s.email = "thomas.peklak@gmail.com" 
  s.homepage = "none yet" 
  s.platform = Gem::Platform::RUBY 
  s.summary = "A semantic offline search" 
  s.description = ""
  candidates = Dir["{bin,docs,lib,conf,templates}/**/*"].to_a
  s.files = candidates.delete_if do |item| 
    item.include?("CVS") || item.include?("rdoc")  || item.include?(".svn") 
  end 
  s.require_path = "lib"
  s.test_file = "tests/notestsyet.rb" 
  s.has_rdoc = true 
  s.extra_rdoc_files = ["README"] 
  s.add_dependency("hpricot", ">= 0.6")
  s.add_dependency("Text", ">= 1.1.2")
  s.add_dependency("filefinder", ">= 0.0.4")
  s.add_dependency("progressbar", ">= 0.0.3")
  s.bindir = 'bin'
  s.executables = ['OfflineSearch']
end
