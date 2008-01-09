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
    end
  end
  #start pagerank with 1 to enable mutliplicatoin pagerank
  def store_file(filename,title,pagerank=1)
    @storage_handler.store_file(filename,title,pagerank)
  end
  def get_file(filename)
    f=@storage_handler.get_file(filename)
    { 'filename'=>f[0],
      'titel'=>f[1],
      'pagerank'=>f[2] }
  end
  
  private
  
  class Sqlite
    def initialize(db)
      require 'rubygems'
      require 'sqlite3'
      @db = SQLite3::Database.new(db)
      sql = "
        create table files ( 
        filename varchar2(255), 
        title varchar2(255), 
        pagerank integer
        ); "
      @db.execute_batch(sql)
    end
    def store_file(filename, title, pagerank)
      @db.execute( "insert into files values ( ?, ?, ? )", filename, title, pagerank)
    end
    def get_file(filename)
      @db.get_first_row( "select * from files where filename = ?", filename)
    end
  end
end

t=Temporary_Storage.new('sqlite')
t.store_file('test.html','Test',20)
r=t.get_file('test.html')
puts r.inspect

