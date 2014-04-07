require_relative 'rjmetrics-client/client'

class RJMetricsClient

  # Constructs a RJMetricsClient instance if it receives valid arguments or will raise an ArgumentError.
  #
  # @param client_id [Integer] your RJMetrics Client ID
  # @param api_key [String] your RJMetrics API Key
  # @param timeout_in_seconds [Integer] seconds to wait for API responses
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
  # @param url [String] Import API url
  # @return [Array] results of each request to RJMetrics Data Import API
  def pushData(table_name, data, url = RJMetrics::Client::API_BASE)
    @client.pushData(table_name, data, url)
  end
end
