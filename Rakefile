$: << File.expand_path(File.dirname(__FILE__)+'/tests')

desc 'perform all tests'
task :tests do
  load 'test_entity_converter.rb'
  
end

desc 'perform entity converter test'
task :test_ec do
  load 'test_entity_converter.rb'
end

task :default do
  puts <<EOS
possible tasks:
  tests
  test_ec     #test the entity converter
EOS
end