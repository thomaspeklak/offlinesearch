#
# * $Author$
# * $Rev$
# * $LastChangedDate$
#

class SearchGenerator
  def initialize(files, terms)
    @files = files
    @terms = terms
    $logger.info("writing data to #{$config['search_generator']['search_data_file']}")
    @search_data_file = File.new($config['search_generator']['search_data_file'],'w')
  end
  
  def generate_terms
    $logger.info("generating term base")
    out = Array.new
    out << "vars terms = {"
    @terms.each do |term, reference|
      out << "'#{term}':["
      docs = Hash.new
      reference.each { |r| docs.has_key?(r.document.ID)? docs[r.document.ID]+=r.rank : docs[r.document.ID] = r.rank }
      docs.sort{ |a,b| a[1]<=>b[1]}.reverse.each{ |doc_ID, rank| out << "[#{doc_ID},#{rank}],"}
      out << "],\n"
    end
    @search_data_file.puts out.join + "}"
  end
  
  def generate_files
    $logger.info("generating file base")
    out = Array.new
    out << "vars files = {"
    @files.each_value do |f|
      out << "#{f.ID}=['#{f.title}','#{f.name}',#{f.page_rank}],"
    end
    @search_data_file.puts out.join + "}"    
  end
  
  def generate_templates
    
  end
  
  def cleanup
    @search_data_file.close
  end
end