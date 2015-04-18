require "rollbar"
require "retries"

Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
  config.environment = `hostname`.strip
end

def log_errors?
  Rollbar.configuration.environment != ENV['DEVELOPMENT_HOSTNAME']
end

def with_error_reporting
  with_retries(retry_params) do
    yield
  end
rescue Exception => exception
  if log_errors?
    Rollbar.error(exception)
  end
  raise
end

def retry_params
  {
    max_tries: 8,
    base_sleep_seconds: 1,
    max_sleep_seconds: 60,
    handler: proc do |exception, attempt_number, total_delay|
      if log_errors?
        Rollbar.warning(exception,
          "Attempt ##{attempt_number}, retrying after #{total_delay}s")
      end
    end
  }
end

