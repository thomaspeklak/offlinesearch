# CRAWLER
# searches dirctory for files
# parses files for keywords and pagerank

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
          xml = REXML::Document.new(lines)
          title=xml_tag(xml,'title')
          h1=xml_tag(xml,'h1')
          h2=xml_tag(xml,'h2')
          a=xml_tag(xml,'a')
          href= Array.new
          a.each do |anker|
            link=anker.parent.attributes.get_attribute('href').value
            #TODO edit link to relative from baspath
            href.push(resolve_link(link, File.dirname(file))) unless link.nil?
          end
        rescue REXML::ParseException
          # no valid xhtml
          # try to retrieve as much information as possible
          title=text_tag(lines,'title')          
          h1=text_tag(lines,'h1')
          h2=text_tag(lines,'h2')
          a=text_tag(lines,'a')
        end
        
#        @storage.store_file(file,title)
#        @storage.store_term(h1,7)
        @storage.store_links(href) unless href.nil?
#        print_var(h2,15)
#        print_var(a,25)
      end
    end
  end

  def get_stored_files
    s=@storage.get_files
    puts s.inspect
  end
  ###### HELPER METHODS
  private
  
  def tag_content(text,tag)
    if text =~ /<#{tag}[^>]*>(.*)<\/#{tag}>/i
      strip_tags($1)
    else
      nil
    end
  end

  def strip_tags(text)
    text.gsub(/<[^>]*>/,'') unless text.nil?
  end

  def xml_tag(xml,tag)
    xml.elements.each("//#{tag}//text()") 
  end

  def text_tag(text,tag)
     strip_tags(tag_content(text,tag))
  end

  def print_var(var,indent)
    var.each  { |v|  puts " "*indent+"#{v}"}      unless var.nil?
  end  
  
  def resolve_link(link,dir)
    case 
      when link =~ /^(http|ftp)/
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
