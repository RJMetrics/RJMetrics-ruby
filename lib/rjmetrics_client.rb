class RJMetricsClient

  def initialize(client_id, api_key, timeout_in_seconds = 10)
    @client = Client.new(client_id, api_key, timeout_in_seconds).validateConstructorArgs
    if not @client.authenticated?
      raise Client::UnableToConnectException, "Connection failed. Please double check your credentials."
    end
  end
end

require 'rjmetrics-client/client'

