require 'rest_client'
require 'json'
require 'enumerator'

class Client

 # default RJMetrics Data Import API url
 API_BASE = "https://connect.rjmetrics.com/v2"
 # RJMetrics Sandbox API url
 SANDBOX_BASE = "https://sandbox-connect.rjmetrics.com/v2"
 # Datapoints to push at a time
 BATCH_SIZE = 100

  # Constructs a Client instance if it receives valid arguments or will raise an ArgumentError.
  #
  # @param client_id [Integer] your RJMetrics Client ID
  # @param api_key [String] your RJMetrics API Key
  # @param timeout_in_seconds [Integer] seconds to wait for API responses or nil
  def initialize(client_id, api_key, timeout_in_seconds = 10)
    validateConstructorArgs(client_id, api_key, timeout_in_seconds)
    @client_id = client_id
    @api_key = api_key
    @timeout_in_seconds = timeout_in_seconds
  end

  # Checks if the provided Client ID and API Key are valid credentials by requestin from the RJMetrics API Sandbox.
  def authenticated?
    test_data = {:keys => [:id], :id => 1}
    begin
      pushData("test", test_data, SANDBOX_BASE)
    rescue InvalidRequestException
      return false
    end
    return true
  end

  # Sends data to RJMetrics Data Import API in batches of 100.
  #
  # @param table_name [String] the table name you wish to store the data
  # @param data [Hashamp] or Array of Hashmaps of data points that will get sent
  # @param url [String] Import API url or nil
  # @return [Array] results of each request to RJMetrics Data Import API
  def pushData(table_name, data, url = API_BASE)
    responses = Array.new
    validatePushDataArgs(table_name, data, url)

    if not data.is_a? Array
      data = Array.[](data)
    end

    data.each_slice(BATCH_SIZE) {|batch_data|
      puts "pushing batch of #{batch_data.count} data points"
      responses << makePushDataAPICall(table_name, batch_data, url)
    }
    return responses
  end

  private

  def validateConstructorArgs(client_id, api_key, timeout_in_seconds)
    if not client_id.is_a? Integer or client_id <= 0
      raise ArgumentError, "Invalid client ID: #{client_id} -- must be a positive integer."
    end

    if not timeout_in_seconds.is_a? Integer or timeout_in_seconds <= 0
      raise ArgumentError, "Invalid timeout: #{timeout_in_seconds} -- must be a positive integer."
    end

    if not api_key.is_a? String
      raise ArgumentError, "Invalid API key: #{api_key} -- must be a string."
    end
  end

  def validatePushDataArgs(table_name, data, url)
    if not data.is_a? Hash and not data.is_a? Array
      raise ArgumentError, "Invalid data -- must be a valid Ruby Hash or Array."
    end

    if not table_name.is_a? String
      raise ArgumentError, "Invalid table name: '#{table_name}' -- must be a string."
    end

    if not url.is_a? String
      raise ArgumentError, "Invalid url: '#{url}' -- must be a string."
    end
  end

  def makePushDataAPICall(table_name, data, url = API_BASE)
    request_url = "#{url}/client/#{@client_id}/table/#{table_name}/data?apikey=#{@api_key}"

    begin
      response = RestClient.post(
        request_url,
        data.to_json,
        {
          :content_type => :json,
          :accept => :json,
          :timeout => @timeout_in_seconds
        }
      )
      return response
    rescue RestClient::Exception => error
      response = JSON.parse(error.response)
      raise InvalidRequestException,
        "The Import API returned: #{response['code']} #{response['message']}. Reasons: #{response['reasons']}"
    end
  end

  class UnableToConnectException < RuntimeError
  end
  class InvalidRequestException < RuntimeError
  end
end
