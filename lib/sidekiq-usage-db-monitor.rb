require "sidekiq"
require "sidekiq/usage-db-monitor"
require "sidekiq/usage-db-monitor/db_redis_logger"

module Sidekiq
  module UsageDbMonitor
    if [nil, 'constant'].include?(Sidekiq.server?)
      redis_conn = { host: ENV['REDIS_HOST'] || 'localhost',
      	             port: ENV['REDIS_PORT'] || '6379' }
      ActiveRecord::Base.logger = Logger.new(Sidekiq::UsageDbMonitor::DBRedisLogger.new(redis_conn))
    end
  end
end
