# temporary storage
# class to store crawled data before the date is written to a file
#
# options:
#   datebase
#     sqlite, mysql
#     filesystem
#
# * $Author$
# * $Rev$
# * $LastChangedDate$

class Temporary_Storage
  attr_reader :storage_handler
  
  # initializes the storage handler
  def initialize(mode)
    @storage_handler=case
      when mode=='sqlite': Sqlite.new('storage.db')
      when mode=='memory': Memory.new
      else
        $logger.error("no appropriate stroage is selected\nvalid options:\n\tsqlite\n\tmemory")
        exit
    end
  end

  # stores file name, title and page rank.
  # start pagerank with 1 to enable mutliplicatoin pagerank
  def store_file(filename,title,pagerank=1)
     @storage_handler.store_file(filename,title,pagerank)
  end
  
  #stores the term and term rank
  def store_term(term,rank)
    @storage_handler.store_term(term,rank)
  end

  # stores an array of links
  def store_link(links)
    @storage_handler.store_link(links)
  end

  # returns a hash of a stored file
  def get_file(filename)
    f=@storage_handler.get_file(filename)
    { 'filename'=>f[0],
      'titel'=>f[1],
      'pagerank'=>f[2] }
  end
  
  # returns a hash of stored files
  def get_files
    f=@storage_handler.get_files
  end
  
  # returns an array of links
  def get_links
    @storage_handler.get_links
  end
  
  # returns a hash of terms
  def get_terms
    @storage_handler.get_terms
  end
  
  # calculates the page rank
  # the page rank equals the number of inbound links or if none 1 
  def calculate_pageranks_from_links
    @storage_handler.calculate_pageranks_from_links
  end
  
  private
  
  # implements a storage handler in the memory
  class Memory
    def initialize
      @files = Hash.new
      @terms = Terms.new
      @links = Links.new
      @current_doc = nil
    end
    
    #stores the file in the files hash
    def store_file(filename,title,pagerank=1)
      @files[filename] = @current_document = Document.new(filename, title, pagerank)
    end
    
    # stores a term in the terms class
    def store_term(term,rank)
      @terms.store(term, Term2Document.new(@current_document,rank))
    end
    
    # stores a link in the link class
    def store_link(links)
      @links.add(links)
    end
    
    def get_file(filename)
      
    end
    
    # returns the files hash
    def get_files
      @files
    end
    
    # returns a terms hash
    def get_terms
      @terms.get_all
    end
    
    # returns an array of links
    def get_links
      @links.get_all
    end
    
    # calculates the page rank
    # the page rank equals the number of inbound links or if none 1     
    def calculate_pageranks_from_links
      @links.get_all.each do |link, rank|
        @files[link].page_rank=rank if @files.has_key?(link)
      end
    end
    
    private
    
    # represents a document. stores an internal id, the file name, title and page rank. all attributes are accessible
    class Document
      @@ID=0
      attr_accessor :ID, :name, :title, :page_rank
      def initialize(name,title,page_rank)
        @ID= @@ID+=1
        @name = name
        @title = title
        @page_rank = page_rank
      end
    end
    
    # represents a hash of terms and their corresponding documents
    class Terms
      def initialize
        @terms = Hash.new
      end
      
      # stores a term in the terms hash with the corresponding document or adds the document to a term if the term already exists in the hash
      def store(term,term2document)
        @terms.has_key?(term) ? @terms[term] << term2document : @terms[term]=[term2document]
      end

      # returns a term hash
      def get_one(term)
        @terms[term]
      end
      
      # returns the terms hash
      def get_all
        @terms
      end
    end
    
    # represents a link from a term to a document. the link includes the semantic value of the term. all attributes are accesible
    class Term2Document
      attr_accessor :document, :rank
      def initialize(document, rank)
        @document = document
        @rank = rank
      end
    end
    
    # represents unique links of all indexed documents
    class Links
      def initialize
        @links = Hash.new
      end
      
      # adds a link to the hash or increases the link value by one if the link already exists
      def add(links)
        links.each{ |link| @links.has_key?(link)? @links[link]+=1 : @links[link]=1 }
      end
      
      # returns all links
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
