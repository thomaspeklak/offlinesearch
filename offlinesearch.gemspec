# TRICKY: spec needs to be global otherwise rake does not load it
$spec = Gem::Specification.new do |s| 
  s.name = "OfflineSearch" 
  s.version = "0.2.6"
  s.author = "Thomas Peklak" 
  s.email = "thomas.peklak@gmail.com" 
  s.platform = Gem::Platform::RUBY 
  s.summary = "A semantic offline search"
	s.description = "OfflineSearch is a semantic offline search generator. It scans a directory of html files and generates a javascript search data file. This was primarly written for an offline html documentation and this is also the main target group. Of course it can be be useful on small websites, too."
  s.require_path = "lib"
  candidates = Dir.glob("{bin,docs,lib,conf,templates}/**/*") 
  s.files = candidates.delete_if do |item| 
    item.include?("CVS") || item.include?("rdoc")  || item.include?(".svn") 
  end 
  s.test_files = Dir["{tests}/test_*.rb"].to_a
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