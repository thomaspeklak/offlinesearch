# generates the data for the search
#
# * $Author$
# * $Rev$
# * $LastChangedDate$
#

class SearchGenerator
  # needs files and terms and an entry in the config representing the location of the javascript file
  def initialize(files, terms)
    @files = files
    @terms = terms
    $logger.info("writing data to #{$config['search_generator']['search_data_file']}")
    @search_data_file = File.new($config['search_generator']['search_data_file'],'w')
  end
  
  # generates the search data
  def generate
    ($config['search_generator']['use_double_metaphone'] && $config['search_generator']['use_double_metaphone'] == true)? generate_terms_for_dm : generate_terms
    generate_files
    generate_relative_path
    generate_frequency_file if ($config['search_generator']['output_frequency_to'])
    generate_double_metaphone if ($config['search_generator']['use_double_metaphone'] && $config['search_generator']['use_double_metaphone'] == true)
    cleanup    
  end
  
  private
  # generates a javascript hash of the indexed terms and writes it to the javascript file
  # term => document id, rank
  def generate_terms
    $logger.info("generating term base")
    out = Array.new
    out << "var terms = {"
    @terms.each do |term, reference|
      out << "'#{term}':["
      docs = Hash.new
      reference.each { |r| docs.has_key?(r.document.ID)? docs[r.document.ID]+=r.rank : docs[r.document.ID] = r.rank }
			# because of a javascript performance issue with nested arrays, the page id and the page rank are put into a string and split in the javascript search an demand
      docs.sort{ |a,b| a[1]<=>b[1]}.reverse.each{ |doc_ID, rank| out << "'#{doc_ID}-#{rank}',"}
      out << "],"
    end
    @search_data_file.puts out.join.gsub(',]',']')[0..-2] + "};"
  end
	

  # generates a javascript hash of the indexed terms and writes it to the javascript file
  # term => document id, rank
  def generate_terms_for_dm
    $logger.info("generating term base")
    outTerms = Array.new
    outTerms << "var terms = {"
    out = Array.new
		out << "var ranks = ["
		i = 0
    @terms.each do |term, reference|
      outTerms << "'#{term}':#{i},"
			i += 1
			out<<"["
      docs = Hash.new
      reference.each { |r| docs.has_key?(r.document.ID)? docs[r.document.ID]+=r.rank : docs[r.document.ID] = r.rank }
			# because of a javascript performance issue with nested arrays, the page id and the page rank are put into a string and split in the javascript search an demand
      docs.sort{ |a,b| a[1]<=>b[1]}.reverse.each{ |doc_ID, rank| out << "'#{doc_ID}-#{rank}',"}
      out << "],"
    end
		@search_data_file.puts outTerms.join.gsub(',]',']')[0..-2] + '};'
    @search_data_file.puts out.join.gsub(',]',']')[0..-2] + "];"
  end
  
  # generates a javascript hash of file ids => title, file name, pagerank
  def generate_files
    $logger.info("generating file base")
    out = Array.new
    out << "var files = {"
    @files.each_value do |f|
      out << "#{f.ID}:[\"#{f.title}\",'#{f.name[1..-1]}',#{f.page_rank}],"
    end
    @search_data_file.puts out.join[0..-2] + "};"    
  end
  
  # stores the relative path in a vairable
  def generate_relative_path
    $logger.info("generating relative path")
    @search_data_file.puts "var rel_path = '#{$config['search_generator']['relative_path_to_files'].gsub(/\/$/,'')}/';" if $config['search_generator'].has_key?('relative_path_to_files')  && $config['search_generator']['relative_path_to_files']
  end
  
  def generate_frequency_file
    $logger.info("generating frequency file")
    File.open($config['search_generator']['output_frequency_to'],'w') do |f|
      @terms.each do |term,reference|
        f.puts "#{term} #{reference.size}"
      end
      
    end
  end

  def generate_double_metaphone()
    $logger.info("generating double metaphone data")
    require 'Text'
    out = Array.new
    out << 'var dm_data = ['
    @terms.each do |t,r|
      temp =  Text::Metaphone.double_metaphone(t)
      out <<  "['#{temp[0]}'#{(temp[1])? ',\''+temp[1]+'\'':nil}],"
		end
    @search_data_file.puts out.join[0..-2] + "];"
  end
  
  # performs cleanup operations
  def cleanup
    @search_data_file.close
  end
end