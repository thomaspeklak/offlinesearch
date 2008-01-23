# CRAWLER
# searches dirctory for files
# parses files for keywords, semantic keyword rank and pagerank
#
# * $Author$
# * $Rev$
# * $LastChangedDate$

require 'find'
require 'rexml/document'
require 'rubygems'
require 'hpricot'
require 'htmlentities'
require 'Kconv'

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
    filter=$config['crawler']['docs']
    test=''
    filter.each { |fi|  test+=".*#{fi}|"}
    @files = Array.new()
    Find.find(@resource) do |f|
      if FileTest.file?f
        if File.basename(f) =~ /(#{test[0..-2]})$/i
          @files.push(f) unless File.basename(f)=~/#{$config['crawler']['exceptions']}/i
        end
      end
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
        lines = Kconv.toutf8(lines) unless Kconv.guess(lines) == NKF::UTF8
        begin
          #try to parse the html as xml
          doc = XmlCrawler.new(lines,file,@storage)
        rescue REXML::ParseException
          #as a fallback use hpricot
          $logger.warn("file not valid XHTML- trying to rescue")
          doc = HpricotCrawler.new(lines,file,@storage)
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
  
  include 'doc_crawler'
  
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