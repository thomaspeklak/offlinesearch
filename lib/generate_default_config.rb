# generates a default configuration file in the current path
#
# * $Author$
# * $Rev$
# * $LastChangedDate$
#
require 'fileutils'
include FileUtils
cp(File.dirname(__FILE__)+'config.yaml','./')