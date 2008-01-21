# CRAWLER
# searches dirctory for files
# parses files for keywords and pagerank
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

  def initialize
    @resource = $config['crawler']['docpath']
    require "temporary_storage"
    @storage=Temporary_Storage.new($config['storage'])
  end

  def find_files()
    filter=$config['crawler']['docs']
    test=''
    filter.each { |fi|  test+=".*#{fi}|"}
    @files = Array.new()
    Find.find(@resource) do |f|
      if FileTest.file?f
        if File.basename(f) =~ /(#{test[0..-2]})$/i
          @files.push(f)
        end
      end
    end
    @files
  end

  def parse_files
    @files.each do |file|
      $logger.info("processing #{file}")
      lines=''
      File.open(file) do |f|
        while line=f.gets
          lines+=Kconv.toutf8(line.chomp)
        end
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

  def get_stored_files
    @storage.get_files.inspect
  end
  
  def get_terms
    @storage.get_terms
  end

  ###### HELPER METHODS
  private
  
  class DocCrawler
    def resolve_link(link,dir)
      case 
        when link =~ /^(http|ftp|mailto)/
          return nil
        when link =~ /^[\/a-zA-Z0-9_-]/
          return dir+'/'+link
        when link =~ /^\./
          return File.expand_path(dir+'/'+link)
        else
          return nil
      end
    end
    
    def crawler_and_store
      @storage.store_file(@file,get_title)
      @storage.store_link(get_hrefs)
      split_and_store      
    end

    private
    
    def split_and_store()
      get_texts.each do |text_block|
        rank=text_block.semantic_value
        HTMLEntities::decode_entities(text_block.to_s.downcase).split(/[^a-zA-ZäöüÄÖÜß]/).each do |term|
          @storage.store_term(term,rank)
        end
      end
    end
  end
  
  # This class parses a file and tries to extract semantic information
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
    def crawler_and_store
      @storage.store_file(@file,get_title)
      @storage.store_link(get_hrefs)
      split_and_store
    end
    
    private
    
    def get_title
      @xml.elements.each('//head//title/text()')
    end
    
    def get_texts
      texts=@xml.elements.each("//body//text()")
      texts.delete_if { |t| t.to_s.lstrip.empty?}
      if block_given?
        yield texts
      else
        texts
      end
    end
    
    def get_hrefs
      a=@xml.elements.to_a("//a")
      href= Array.new
      a.each do |anker|
        link=resolve_link(anker.attributes.get_attribute('href').value,File.dirname(@file))
        href << link unless link.nil?
      end
      href
    end
    class REXML::Text
      def self.store_semantics(tags)
        @@semantic_tags=tags
      end
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
  
  class HpricotCrawler < DocCrawler
    def initialize(lines,file,storage)
      @doc = Hpricot(lines)
      @file = file
      @storage = storage
    end
    
    private
    
    def get_title
      @doc.at('//head/title').inner_text
    end
    
    def get_texts
      texts = Array.new
      @doc.traverse_text { |text|  texts << text unless text.to_s.strip.empty?}
      if block_given?
        yield texts
      else
        texts
      end
    end
    
    def get_hrefs
      links = Array.new
      (@doc/'a[@href]').each { |a| links << resolve_link(a.get_attribute('href'),File.dirname(@file)) }
      links
    end
    
    class Hpricot::Text
      def self.store_semantics(tags)
        @@semantic_tags=tags
      end
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