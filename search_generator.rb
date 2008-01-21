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
    @search_data_file.print "{"
    @terms.each do |term, reference|
      @search_data_file.print "'#{term}':["
      docs = Hash.new
      reference.each { |r| docs.has_key?(r.document.ID)? docs[r.document.ID]+=r.rank : docs[r.document.ID] = r.rank }
      docs.sort{ |a,b| a[1]<=>b[1]}.reverse.each{ |doc_ID, rank| @search_data_file.print "[#{doc_ID},#{rank}],"}
      @search_data_file.print "],\n"
    end
    @search_data_file.print "}"
  end
  
  def generate_files
    
  end
  
  def generate_templates
    
  end
  
  def cleanup
    @search_data_file.close
  end
end