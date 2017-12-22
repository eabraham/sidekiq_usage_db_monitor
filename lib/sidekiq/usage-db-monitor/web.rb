require "sidekiq/usage-db-monitor/web_extension"

if defined?(Sidekiq::Web)
  Sidekiq::Web.register Sidekiq::UsageDbMonitor::WebExtension

  if Sidekiq::Web.tabs.is_a?(Array)
    # For sidekiq < 2.5
    Sidekiq::Web.tabs << "Usage DB Monitor"
  else
    Sidekiq::Web.tabs["Usage DB Monitor"] = "usage-db-monitor"
  end
end
