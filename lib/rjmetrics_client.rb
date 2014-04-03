require_relative 'rjmetrics-client/client'

class RJMetricsClient

  def initialize(client_id, api_key, timeout_in_seconds = 10)
    @client = RJMetrics::Client.new(client_id, api_key, timeout_in_seconds)

    if not authenticated?
      raise RJMetrics::Client::UnableToConnectException, "Connection failed. Please double check your credentials."
    end
  end

  # Validates credentials by making a request to the RJMetrics API Sandbox.
  def authenticated?
    return @client.authenticated?
  end

  # Sends data to RJMetrics Data Import API.
  #
  # @param table_name [String] the table name you wish to store the data
  # @param data [Hashamp] or Array of Hashmaps of data points that will get sent
  # @return [Array] results of each request to RJMetrics Data Import API
  def pushData(table_name, data)
    @client.pushData(table_name, data)
  end
end
