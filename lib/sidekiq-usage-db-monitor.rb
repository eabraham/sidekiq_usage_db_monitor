require "sidekiq"
require "sidekiq/usage-db-monitor"
require "sidekiq/usage-db-monitor/db_redis_logger"

module Sidekiq
  module UsageDbMonitor
    if [nil, 'constant'].include?(Sidekiq.server?)
      ActiveRecord::Base.logger = Logger.new(Sidekiq::UsageDbMonitor::DBRedisLogger.new)
    end
  end
end
