$: << File.expand_path(File.dirname(__FILE__)+'/../lib')

require "test/unit"
require "temporary_storage"

class TestTemporaryStorage < Test::Unit::TestCase
  def setup
      $config = {'logger'=> { 'file' => STDOUT, 'level' => 'INFO'}}
      require "log_init"
      @ts = Temporary_Storage.new('memory')
  end
  def test_initialize # (mode)
     assert_equal Temporary_Storage::Memory, @ts.storage_handler.class
     ts2 = Temporary_Storage.new('sqlite')
     assert_equal Temporary_Storage::Sqlite, ts2.storage_handler.class
     File.delete 'storage.db'
  end

  def test_store_file #(filename,title,pagerank=1)
    store_one_file
    assert_equal ({ 'filename'  => @file,
                    'title'     => @name,
                    'pagerank'  => 1 }), @ts.get_file(@file)
    store_one_file_with_page_rank
    assert_equal ({ "title"     =>@name2,
                    "pagerank"  =>10, 
                    "filename"  =>@file2}), @ts.get_file(@file2)
  end

  def test_store_term #(term,rank)
    store_one_file
    @term = 'Testterm'
    @rank = 7
    @ts.store_term(@term, @rank)
    assert_equal 1, @ts.get_terms[@term].size
    assert_equal 7, @ts.get_terms[@term][0].rank
    assert_equal @file, @ts.get_terms[@term][0].document.name
    store_one_file_with_page_rank
    @term2 = 'Testterm2'
    @rank2 = 17
    @ts.store_term(@term, @rank)
    @ts.store_term(@term2, @rank2)
    assert_equal 2, @ts.get_terms[@term].size
    assert_equal 1, @ts.get_terms[@term2].size
    assert_equal 17, @ts.get_terms[@term2][0].rank
    assert_equal @file2, @ts.get_terms[@term2][0].document.name
  end

  def test_store_link
    store_links
    assert_equal ({@link3=>3, @link2=>2, @link1=>1}), @ts.get_links
  end

  def test_get_files
    store_one_file
    store_one_file_with_page_rank
    
    assert_equal Temporary_Storage::Memory::Document, @ts.get_files[@file].class
    assert_equal Temporary_Storage::Memory::Document, @ts.get_files[@file2].class
    assert_equal [@file, @file2], @ts.get_files.keys 
  end

  def test_calculate_pageranks_from_links
    store_files
    store_links
    @ts.calculate_pageranks_from_links
    f = @ts.get_files
    assert_equal 2, f[@file].page_rank
    assert_equal 12, f[@file2].page_rank
    assert_equal 3, f[@file3].page_rank
  end

  private
  def store_one_file
    @file = 'testfile.html'
    @name = 'Testfile'
    @ts.store_file(@file, @name)
  end
  
  def store_one_file_with_page_rank
    @file2 = 'testfile2.html'
    @name2 = 'Testfile2'
    @page_rank2 = 10
    @ts.store_file(@file2, @name2, @page_rank2)
  end
  
  def store_one_file_with_page_rank2
    @file3 = 'testfile3.html'
    @name3 = 'Testfile3'
    @page_rank3 = 3
    @ts.store_file(@file3, @name3, @page_rank3)
  end
  
  def store_links
    @link1 = 'testfile.html'
    @link2 = 'testfile2.html'
    @link3 = 'test3.html'
    @ts.store_link(@link3)
    @ts.store_link(@link2)
    @ts.store_link(@link3)
    @ts.store_link(@link1)
    @ts.store_link(@link3)
    @ts.store_link(@link2)
  end
  
  def store_files
    store_one_file
    store_one_file_with_page_rank
    store_one_file_with_page_rank2
  end
end


