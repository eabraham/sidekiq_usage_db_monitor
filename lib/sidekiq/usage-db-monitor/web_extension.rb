module Sidekiq
  module UsageDbMonitor 
    module WebExtension
      def self.registered(app)
        app.get '/usage-db-monitor' do
	  view_path    = File.join(File.expand_path("..", __FILE__), "views")

          render(:erb, File.read(File.join(view_path, "usage_db_monitor.erb")))
        end
      end
    end
  end
end
