class RJMetricsClient

  def self.hi(client_id, api_key, timeout_in_seconds = 10)
    client = Client.new(client_id, api_key, timeout_in_seconds)
    client.validateArgs
  end
end

require 'rjmetrics-client/client'

