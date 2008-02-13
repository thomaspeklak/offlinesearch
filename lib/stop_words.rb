$stop_words = Hash.new

File.open($config['crawler']['stopwords']) do |f|
  while line = f.gets
    $stop_words[line.chomp]=nil
  end
end