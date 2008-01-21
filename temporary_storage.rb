# temporary storage
# class to store crawled data before the date is written to a file
# options
#   datebase
#     sqlite, mysql
#   filesystem
#
# * $Author$
# * $Rev$
# * $LastChangedDate$

class Temporary_Storage
  attr_reader :storage_handler
  def initialize(mode)
    @storage_handler=case
      when mode=='sqlite': Sqlite.new('storage.db')
      when mode=='memory': Memory.new
      else
        puts "no appropriate stroage is selected\nvalid options:\n\tsqlite\n\tmemory"
        exit
    end
  end

  #start pagerank with 1 to enable mutliplicatoin pagerank
  def store_file(filename,title,pagerank=1)
     @storage_handler.store_file(filename,title,pagerank)
  end
  
  def store_term(term,rank)
    @storage_handler.store_term(term,rank)
  end

  def store_link(links)
    @storage_handler.store_link(links)
  end

  def get_file(filename)
    f=@storage_handler.get_file(filename)
    { 'filename'=>f[0],
      'titel'=>f[1],
      'pagerank'=>f[2] }
  end
  
  def get_files
    f=@storage_handler.get_files
  end
  
  def get_links
    @storage_handler.get_links
  end
  
  def get_terms
    @storage_handler.get_terms
  end
  
  def calculate_pageranks_from_links
    @storage_handler.calculate_pageranks_from_links
  end
  
  private
  
  class Memory
    def initialize
      @files = Hash.new
      @terms = Terms.new
      @links = Links.new
      @current_doc = nil
    end
    
    def store_file(filename,title,pagerank=1)
      @files[filename] = @current_document = Document.new(filename, title, pagerank)
    end
    
    def store_term(term,rank)
      @terms.store(term, Term2Document.new(@current_document,rank))
    end
    
    def store_link(links)
      @links.add(links)
    end
    
    def get_file(filename)
      
    end
    
    def get_files
      @files
    end
    
    def get_terms
      @terms.get_all
    end
    
    def get_links
      @links.get_all
    end
    
    def calculate_pageranks_from_links
      @links.get_all.each do |link, rank|
        @files[link].page_rank=rank if @files.has_key?(link)
      end
    end
    
    private
    
    class Document
      @@id=0
      attr_accessor :name, :title, :page_rank
      def initialize(name,title,page_rank)
        @id= @@id+=1
        @name = name
        @title = title
        @page_rank = page_rank
      end
    end
    
    class Terms
      def initialize
        @terms = Hash.new
      end
      
      def store(term,term2document)
        @terms.has_key?(term) ? @terms[term] << term2document : @terms[term]=[term2document]
      end
      
      def get_one(term)
        @terms[term]
      end
      
      def get_all
        @terms
      end
    end
    
    class Term2Document
      attr_accessor :document, :rank
      def initialize(document, rank)
        @document = document
        @rank = rank
      end
    end
    
    class Links
      def initialize
        @links = Hash.new
      end
      
      def add(links)
        links.each{ |link| @links.has_key?(link)? @links[link]+=1 : @links[link]=1 }
      end
      
      def get_all
        @links
      end
    end
  end
  
  class Sqlite
    def initialize(db)
      require 'rubygems'
      require 'sqlite3'
      @current_file_id = nil
      begin
        File.delete(db)
      rescue
      end
      @db = SQLite3::Database.new(db)
      @db.type_translation = true
      sql = "        
        create table files( 
          id integer not null primary key autoincrement,
          filename varchar2(255), 
          title varchar2(255), 
          pagerank integer
        );
        create table terms(
          id integer not null primary key autoincrement,
          term varchar2(255) unique not null
        );
        create table files_terms(
          file_id integer not null,
          term_id integer not null,
          rank integer not null
        );
        create table links(
          link varchar2(255) not null primary key,
          links_in integer
        )
        "
      @db.execute_batch(sql)
    end
    def store_file(filename, title, pagerank)
      @db.execute( "insert into files (filename, title, pagerank) values ( ?, ?, ? )", filename, title, pagerank)
      @current_file_id = @db.last_insert_row_id()
    end
    
    def store_term(term, rank)
      unless (term_id=@db.get_first_value('select id from terms where term = ?',term)) :
        @db.execute("insert into terms (term) values (?)", term)
        term_id=@db.last_insert_row_id()
      end
      @db.execute("insert into files_terms values (?,?,?)", @current_file_id,term_id,rank)
    end
    
    def store_link(links)
      links.each do |link|
        if(links_in  = @db.get_first_value("select links_in from links where link = ?",link))
          @db.execute("update links set links_in =? where link = ? ",links_in+1,link)
        else
          @db.execute("insert into links values (?,?)", link, 1)
        end
      end
    end
    
    def get_file(filename)
      @db.get_first_row("select * from files where filename = ?", filename)
    end

    def get_files
      @db.execute("select * from files f join files_term ft on f.id = ft.id")
    end
    
    def get_links
      @db.execute("select * from links")
    end
  end
end
