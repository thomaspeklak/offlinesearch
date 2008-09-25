require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rubygems'

load File.dirname(__FILE__) + '/offlinesearch.gemspec'

CLEAN.include("pkg")

desc 'create gem package'
Rake::GemPackageTask.new($spec) do |pkg|
	Rake::Task[:clean].invoke
	pkg.need_tar = true
end

desc 'perform tests'
Rake::TestTask.new(:test) do |t|
   t.test_files = FileList['tests/test_*.rb']
   t.warning = true
end 

desc 'generate development rdocs'
Rake::RDocTask.new(:rdoc_dev) do |rd|
	rd.title = 'OfflineSearch development API'
	rd.main = "README"
	rd.rdoc_files.include("README", "lib/**/*.rb")
	rd.rdoc_dir = 'docs_dev'
	rd.options << "--all"
end

desc 'generate rdocs'
Rake::RDocTask.new(:rdoc) do |rd|
	rd.title = 'OfflineSearch API'
	rd.main = "README"
	rd.rdoc_files.include("README", "lib/**/*.rb")
	rd.rdoc_dir = 'docs'
end

task :default do
  puts <<-EOLS
tasks:
 TESTS
  rake test                           # run tests normally
  rake test TEST=just_one_file.rb     # run just one test file.
  rake test TESTOPTS="-v"             # run in verbose mode
 DOCS
  rake rdoc_dev                       # generate development rdocs
  rake rdoc                           # generate rdocs
 GEMS
	rake gem                            # create gem in pkg dir
  EOLS
end