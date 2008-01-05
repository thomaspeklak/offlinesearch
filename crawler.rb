# CRAWLER
# searches dirctory for files
# parses files for keywords and pagerank

require 'find'
require 'rexml/document'

class Crawler
  def initialize(resource)
    @resource = resource
  end
  attr_reader :resource
  attr_writer :resource
  def find_files(filter)
    @files = Array.new()
    Find.find(@resource) do |f|
      if FileTest.file?f
        if File.basename(f) =~ /#{filter}/i
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
          xml = REXML::Document.new(lines)
          title=xml_tag(xml,'title')
          h1=xml_tag(xml,'h1')
          h2=xml_tag(xml,'h2')
        rescue REXML::ParseException
          # no valid xhtml
          # try to retrieve as much information as possible
          title=text_tag(lines,'title')          
          h1=text_tag(lines,'h1')
          h2=text_tag(lines,'h2')
        end
        puts file
        title.each  { |t|  puts "   #{t}"}      unless title.nil?
        h1.each     { |h|  puts "     #{h}"}    unless h1.nil?
        h2.each     { |h|  puts "       #{h}"}  unless h2.nil?
      end
    end
  end
  def tag_content(text,tag)
    if text =~ /<#{tag}[^>]*>(.*)<\/#{tag}>/i
      strip_tags($1)
    else
      nil
    end
  end
  
  ###### private functions
  private
  
  def strip_tags(text)
    text.gsub(/<[^>]*>/,'') unless text.nil?
  end
  def xml_tag(xml,tag)
    xml.elements.each("//#{tag}//text()") 
  end
  def text_tag(text,tag)
     strip_tags(tag_content(text,tag))
  end
end


t=Crawler.new('/Users/tom/Documents/sabine/sabineirawan.com')
t.find_files('\.html$')
t.parse_files
