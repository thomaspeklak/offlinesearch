$stop_words = Hash.new

File.open(File.dirname(__FILE__) +'/'+$config['crawler']['stopwords']) do |f|
  while line = f.gets
    $stop_words[line]=nil
  end
end