# CRAWLER
# searches dirctory for files
# parses files for keywords, semantic keyword rank and pagerank
#
# * $Author$
# * $Rev$
# * $LastChangedDate$

require 'rexml/document'
require 'rubygems'
require 'hpricot'
require 'Kconv'
require 'entity_converter'
require 'filefinder'

class Crawler
  attr_writer :resource
  # requires a docpath set in the config file and a temporary storage handler
  def initialize
    @resource = $config['crawler']['docpath']
    require "temporary_storage"
    @storage=Temporary_Storage.new($config['storage'])
  end

  # serach the given docpath for files with a valid extension and excludes files that should not be indexed
  # returns an array of files
  def find_files()
    @files = FileFinder::find(@resource,:types=>$config['crawler']['docs'],:excludes=>$config['crawler']['exceptions'])
    if (@files.empty?)
      $logger.error('no files found in directory')
      exit
    end
    @files
  end

  # takes an array of files an iterates through it. each file is read into a string and sent to a doccrawler for further processing
  # if the file is a valid XHTML file, the file is processed with REXML otherwise Hpricot is used and a warning is written to the log
  # no value is returned
  def parse_files
    @files.each do |file|
      $logger.info("processing #{file}")
      File.open(file) do |f|
        lines_array= Array.new
        while line=f.gets
          lines_array << line.chomp
        end
        lines = lines_array.join(' ')
        begin
          #try to parse the html as xml
          doc = XmlCrawler.new(lines,file,@storage)
        rescue REXML::ParseException
          #as a fallback use hpricot
          $logger.warn("not valid XHTML- trying to parse as HTML")
          #convert entities before a new Hpricot doc is created, otherwise the entities are not converted correctly
          doc = HpricotCrawler.new(lines.decode_html_entities,file,@storage)
        end
        doc.crawler_and_store
      end
    end
    @storage.calculate_pageranks_from_links
  end

  # returns a hash of the parsed documents
  def get_stored_files
    @storage.get_files
  end
  
  # returns a hash of the indexed terms with ranks and links to the documents
  def get_terms
    @storage.get_terms
  end

  ###### HELPER METHODS
  private
  
  # This abstract class parses a file and tries to extract semantic information
  class DocCrawler
    # tries to ignore external links an convert internal links
    def resolve_link(link,dir)
      case 
        when link =~ /^(http|ftp|mailto)/
          return nil
        when link =~ /^[\/a-zA-Z0-9_-]/
          return (dir+'/'+link).gsub(/.*#{$config['crawler']['docpath']}/,'')
        when link =~ /^\./
          return (File.expand_path(dir+'/'+link)).gsub(/.*#{$config['crawler']['docpath']}/,'')
        else
          return nil
      end
    end
    
    # method invokes other methods to get certain information about the document. These methods are implemented in the child classes
    def crawler_and_store
      @storage.store_file(resolve_link(@file,File.dirname(@file)),get_title)
      @storage.store_link(get_hrefs)
      split_and_store      
    end

    private
    
    # splits textblocks and stores terms in the storage. this method splits an all characters that are non aplhpa
    def split_and_store()
      get_texts.each do |text_block|
        rank=text_block.semantic_value
        text_block.to_s.downcase.umlaut_to_downcase.decode_html_entities.split(/[^a-zäöüß]/).each do |term|
          @storage.store_term(term,rank) unless (term.size < 2 || $stop_words.has_key?(term))
        end
      end
    end
  end
  
  # parses valid XHTML documents and extracts information
  class XmlCrawler < DocCrawler
    def initialize(lines,file,storage)
      @file = file
      @storage = storage
      begin
        @xml = REXML::Document.new(lines)
      rescue REXML::ParseException
        raise
      end
    end
    
    private
    
    # extracts and returns the title of the document
    def get_title
      @xml.elements.each('//head//title/text()')
    end
    
    # extracts all texts and returns an array of REXML::Texts if no block is given
    # if a block is given then the texts are passed to it
    def get_texts
      texts=@xml.elements.each("//body//text()")
      texts.delete_if { |t| t.to_s.lstrip.empty?}
      if block_given?
        yield texts
      else
        texts
      end
    end
    
    # returns an array of internal links in the document
    def get_hrefs
      a=@xml.elements.to_a("//a")
      href= Array.new
      a.each do |anker|
        link=resolve_link(anker.attributes.get_attribute('href').value,File.dirname(@file)) if anker.attributes.get_attribute('href')
        href << link unless link.nil?
      end
      href
    end
    
    # extends REXML::Text with the functionaliy to extract semantic information
    class REXML::Text
      # stores an array of meaningful tags with their rank value
      def self.store_semantics(tags)
        @@semantic_tags=tags
      end
      
      # extracts the semantic value of a text block
      def semantic_value
        REXML::Text.store_semantics($config['crawler']['tags'].keys) unless defined?(@@semantic_tags)
        rank = 1
        node = parent
        while @@semantic_tags.include?(node.name)
          rank += $config['crawler']['tags'][node.name]
          node = node.parent
        end
        rank
      end
    end
  end
  
  # parses non valid XHTML documents and extracts information
  class HpricotCrawler < DocCrawler
    def initialize(lines,file,storage)
      @doc = Hpricot(lines)
      @file = file
      @storage = storage
    end
    
    private
    
    # extracts and returns the title of the document
    def get_title
      @doc.at('//head/title').inner_text
    end
    
    # extracts all texts and returns an array of REXML::Texts if no block is given
    # if a block is given then the texts are passed to it
    def get_texts
      texts = Array.new
      @doc.traverse_text { |text|  texts << text unless text.to_s.strip.empty?}
      if block_given?
        yield texts
      else
        texts
      end
    end
    
    # returns an array of internal links in the document
    def get_hrefs
      links = Array.new
      (@doc/'a[@href]').each { |a| links << resolve_link(a.get_attribute('href'),File.dirname(@file)) }
      links
    end

    # extends Hpricot::Text with the functionaliy to extract semantic information    
    class Hpricot::Text
      # stores an array of meaningful tags with their rank value
      def self.store_semantics(tags)
        @@semantic_tags=tags
      end

      # extracts the semantic value of a text block
      def semantic_value
        Hpricot::Text.store_semantics($config['crawler']['tags'].keys) unless defined?(@@semantic_tags)
        rank = 1
        node = parent
        while @@semantic_tags.include?(node.name)
          rank += $config['crawler']['tags'][node.name]
          node = node.parent
        end
        rank
      end
    end
  end
end