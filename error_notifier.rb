require "rollbar"

Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
  config.environment = `hostname`.strip
end

def with_error_reporting
  yield
rescue Exception => e
  Rollbar.error(e) unless Rollbar.configuration.environment == ENV['DEVELOPMENT_HOSTNAME']
  raise
end
