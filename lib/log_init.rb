# configures the ruby logger
#
# * $Author$
# * $Rev$
# * $LastChangedDate$
#

require 'logger'
unless ($config.has_key?('logger'))
  $logger = Logger.new(STDOUT)
  $logger.level = Logger::INFO
else
  $logger = ($config['logger']['file'] == 'STDOUT')? Logger.new(STDOUT) : Logger.new($config['logger']['file'])
  $logger.level = eval("Logger::#{$config['logger']['level'].upcase}")
end

