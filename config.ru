require 'sidekiq/web'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sidekiq-usage-db-monitor'

run Sidekiq::Web
