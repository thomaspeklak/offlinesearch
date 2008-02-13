# generates template files
# currently only one template is supported
#
# * $Author: tom $
# * $Rev: 102 $
# * $LastChangedDate: 2008-02-12 16:42:20 +0100 (Tue, 12 Feb 2008) $
#

class TemplateGenerator
  def initialize(template)
    @template = template
    find_files
    copy_files_to_current_path
  end
  
  private
  # serach the given docpath for files
  # returns an array of files
  def find_files()
    require 'find'
    directory = File.dirname(__FILE__) + @template
    @files = Array.new()
    Find.find(directory) do |f|
      if FileTest.file?f
        @files.push(f)
      end
    end
    @files
  end

  #copies the found files in the current path
  def copy_files_to_current_path()
    require 'fileutils'
    include FileUtils
    @files.each do |f|
      cp(f,'./')
    end
  end
end