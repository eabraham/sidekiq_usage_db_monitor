module Sidekiq
  module UsageDbMonitor 
    module WebExtension
      def self.registered(app)
        app.get '/usage-db-monitor' do
	        view_path  = File.join(File.expand_path("..", __FILE__), "views")
          asset_path = File.join(File.expand_path("..", __FILE__), "assets")

          render(:erb, File.read(File.join(view_path, "usage_db_monitor.erb")), locals: {view_path: view_path, asset_path: asset_path})
        end

        app.get '/table-duration' do
          min_since_epoch = params['min_since_epoch'].to_i - 1
          action = params['type']

          @redis = Redis.new({})
          durations = @redis.hgetall("sidekiq-job-planner-by-table-duration-#{action}-#{min_since_epoch}")

          tables = ActiveRecord::Base.connection.tables

          tables.each do |table, value|
            durations[table] = durations[table].to_i / 1000.0
          end
          payload = {
              durations: durations,
              metadata:  {
                min_since_epoch: min_since_epoch
              }
            }
          json(payload)
        end
      end
    end
  end
end