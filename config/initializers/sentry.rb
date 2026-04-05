# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = 'https://bdb38e08c1051bbaad5f5b44a9f615ef@o4506141152247808.ingest.us.sentry.io/4511169643020288'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 1.0
  # Add data like request headers and IP for users,
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = true
end