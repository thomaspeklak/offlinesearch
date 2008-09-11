$: << File.expand_path(File.dirname(__FILE__)+'/tests')

desc 'perform all tests'
task :tests do
  load 'test_entity_converter.rb'
  load 'test_option_validator.rb'
  load 'test_temporary_storage.rb'
  load 'test_stopwords.rb'
end

desc 'perform entity converter test'
task :test_ec do
  load 'test_entity_converter.rb'
end

desc 'perform option validator test'
task :test_ov do
  load 'test_option_validator.rb'
end

desc 'perform temporary storage test'
task :test_ts do
  load 'test_temporary_storage.rb'
end

desc 'perform stop words'
task :test_sw do
  load 'test_stopwords.rb'
end

task :default do
  puts <<EOS
possible tasks:
  tests
  test_ec     #test the entity converter
  test_ov     #test the option validator
  test_ts     #test temporary storage
  test_sw     #test stop words
EOS
end