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
      when mode=='sqlite': Sqlite.new('temporal_storage.db')
    end
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
    endÅ
  end
end

t=Temporal_Storage.new('sqlite')