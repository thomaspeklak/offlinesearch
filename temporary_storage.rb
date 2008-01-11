# temporary storage
# class to store crawled data before the date is written to a file
# options
#   datebase
#     sqlite, mysql
#   filesystem

class Temporary_Storage
  attr_reader :storage_handler
  def initialize(mode)
    @storage_handler=case
      when mode=='sqlite': Sqlite.new('storage.db')
      else
        puts "no appropriate stroage is selected\nvalid options:\n\tsqlite"
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

  def get_file(filename)
    f=@storage_handler.get_file(filename)
    { 'filename'=>f[0],
      'titel'=>f[1],
      'pagerank'=>f[2] }
  end
  
  def get_files
    f=@storage_handler.get_files
  end
  
  private
  
  class Sqlite
    def initialize(db)
      require 'rubygems'
      require 'sqlite3'
      @current_file_id = nil
      @db = SQLite3::Database.new(db)
      @db.type_translation = true
      sql = "
        create table files ( 
          id integer not null primary key autoincrement,
          filename varchar2(255), 
          title varchar2(255), 
          pagerank integer
        );
        create table terms (
          id integer not null primary key autoincrement,
          term varchar2(255) unique not null
        );
        create table files_terms(
          file_id integer not null,
          term_id integer not null,
          rank integer not null
        );
        create table links(
          link varchar2(255) not null,
          links_number integer
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
    
    def get_file(filename)
      @db.get_first_row("select * from files where filename = ?", filename)
    end

    def get_files
      @db.execute("select * from files")
    end
  end
end
