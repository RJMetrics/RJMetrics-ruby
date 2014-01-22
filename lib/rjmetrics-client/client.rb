require 'rest_client'
require 'json'

class Client

 API_BASE = "https://connect.rjmetrics.com/v2"
 SANDBOX_BASE = "https://sandbox-connect.rjmetrics.com/v2"

  def initialize(client_id, api_key, timeout_in_seconds = 10)
    @client_id = client_id
    @api_key = api_key
    @timeout_in_seconds = timeout_in_seconds
  end

  def validateConstructorArgs
    if not @client_id.is_a? Integer or @client_id <= 0
      raise ArgumentError, "Invalid client ID: #{@client_id} -- must be a positive integer."
    end

    if not @timeout_in_seconds.is_a? Integer or @timeout_in_seconds <= 0
      raise ArgumentError, "Invalid timeout: #{@timeout_in_seconds} -- must be a positive integer."
    end

    if not @api_key.is_a? String
      raise ArgumentError, "Invalid API key: #{@timeout_in_seconds} -- must be a string."
    end

    return self
  end

  def authenticated?
    test_data = JSON.parse("[{\"keys\":[\"id\"],\"id\":1}]")
    begin
      response = pushData("test", test_data, SANDBOX_BASE)
    rescue InvalidRequestException
      return false
    end
    return true
  end

  def pushData(table_name, data, url = API_BASE)
    makePushDataAPICall(table_name, data, url)
  end

  private

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
