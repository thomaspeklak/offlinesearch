# configures the ruby logger
#
# * $Author$
# * $Rev$
# * $LastChangedDate$
#

require 'logger'
$logger = ($config['logger']['file'] == 'STDOUT')? Logger.new(STDOUT) : Logger.new($config['logger']['file'])
$logger.level = eval("Logger::#{$config['logger']['level'].upcase}")