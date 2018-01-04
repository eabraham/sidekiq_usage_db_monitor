module Sidekiq
  module UsageDbMonitor 
    class DBRedisLogger
      def initialize(args={})
        @redis = Redis.new(args)
        @tables = nil
      end

      def write(*args)
        raw_log = args.to_s
        timestamp = Time.current.to_i / 60
        puts raw_log
        sql = ""
        if raw_log.include?('\e[1m\e[32m') # Insert
          parse=raw_log.split('\e[1m\e[32m')
          sql = parse.last
          duration_str = /(?:\()([A-z0-9.]*)(?:\))/.match(parse.first).try(:[],1)
          duration = duration_str[0..-3].try(:to_d)
          query = sql.split('RETURNING').first
          log_table_by_action(timestamp, query, 'write', duration)
        elsif raw_log.include?('\e[1m\e[34m') # Select
          parse = raw_log.split('\e[1m\e[34m')
          sql=parse.last
          duration_str = /(?:\()([A-z0-9.]*)(?:\))/.match(parse.first).try(:[],1)
          duration = duration_str[0..-3].try(:to_d)
          query = sql.split('\e[0m').first
          log_table_by_action(timestamp, query, 'read', duration)
        elsif raw_log.include?('\e[1m\e[35m') #transaction
          sql=raw_log.split('\e[1m\e[35m').last
          return # don't need a log
        else
          raise 'Error unexpected log format.'
        end
        @redis.hincrby("sidekiq-job-planner-by-query-count-#{timestamp}", query, 1)
      end

      def close
        @redis.commit
      end

      private

      def log_table_by_action(timestamp, query, action, duration)
        tables.each do |table|
          if query.downcase.include?(table)
            @redis.hincrby("sidekiq-job-planner-by-table-count-#{action}-#{timestamp}", table, 1)
            @redis.expire("sidekiq-job-planner-by-table-count-#{action}-#{timestamp}", 82800)
            @redis.hincrby("sidekiq-job-planner-by-table-duration-#{action}-#{timestamp}", table, duration.to_i*1000)
            @redis.expire("sidekiq-job-planner-by-table-duration-#{action}-#{timestamp}", 82800)
            break
          end
        end
      end

      def tables
        @tables ||= ActiveRecord::Base.connection.tables
      end
    end
  end
end