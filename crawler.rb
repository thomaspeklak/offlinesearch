# CRAWLER
# searches dirctory for files
# parses files for keywords and pagerank
#
# * $Author$
# * $Rev$
# * $LastChangedDate$

require 'find'
require 'rexml/document'

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
      lines=''
      File.open(file) do |f|
        while line=f.gets
          lines+=line.chomp
        end
        begin
          #try to parse the html as xml
          doc = XmlCrawler.new(lines,file,@storage)
          doc.crawler_and_store
        rescue REXML::ParseException
          # no valid xhtml
          # try to retrieve as much information as possible
          title=text_tag(lines,'title')          
          #h1=text_tag(lines,'h1')
          #h2=text_tag(lines,'h2')
          a = Array.new
          href = Array.new
          #a_href_and_content(lines).each do |links|
          #  href << resolve_link(links[0],File.dirname(file))
          #  a << links[1]
          #end
          #@storage.store_file(file,title)
          #@storage.store_term(h1,7)
          #@storage.store_link(href) unless href.nil?
        end
        
      end
    end
  end

  def get_stored_files
    puts @storage.get_files.inspect
    puts @storage.get_links.inspect
    puts @storage.get_terms.keys
  end
  ###### HELPER METHODS
  private
  
  def tag_content(text,tag)
    #TODO not greedy regular expression
    if m = text.scan(/<#{tag}[^>]*>.*?<\/#{tag}>/i)
      strip_tags(m)
    else
      nil
    end
  end

  def a_href_and_content(text)
    m = text.scan(/<a href=["'](.*?)["'][^>]*>(.*?)<\/a>/i)
  end

  def strip_tags(matches)
    result = Array.new
    matches.each { |t| result << t.gsub(/<[^>]*>/,'') unless t.nil? }
    result
  end


  def text_tag(text,tag)
     strip_tags(tag_content(text,tag))
  end

  def print_var(var,indent)
    var.each  { |v|  puts " "*indent+"#{v}"}      unless var.nil?
  end  
  
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
  end
  
  # This class parses a file and tries to extract semantic information
  class XmlCrawler < DocCrawler
    def initialize(lines,file,storage)
      puts file
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
    
    def split_and_store()
      get_texts.each do |text_block|
        rank=text_block.semantic_value.inspect
        text_block.to_s.split.each do |term|
          #TODO unescape HTML entities
          @storage.store_term(term,rank)
        end
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
end