require 'rest_client'
require 'json'

class Client

 API_BASE = "https://connect.rjmetrics.com/v2"
 SANDBOX_BASE = "https://sandbox-connect.rjmetrics.com/v2"

  def initialize(client_id, api_key, timeout_in_seconds = 10)
    validateConstructorArgs(client_id, api_key, timeout_in_seconds)
    @client_id = client_id
    @api_key = api_key
    @timeout_in_seconds = timeout_in_seconds
  end

  def authenticated?
    test_data = {:keys => [:id], :id => 1}
    begin
      pushData("test", test_data, SANDBOX_BASE)
    rescue InvalidRequestException
      return false
    end
    return true
  end

  def pushData(table_name, data, url = API_BASE)
    validatePushDataArgs(table_name, data)

    if not data.is_a? Array
      data = Array.[](data)
    end

    return data.map{ |data_point| makePushDataAPICall(table_name, data_point, url) }
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

  def validatePushDataArgs(table_name, data)
    if not data.is_a? Hash and not data.is_a? Array
      raise ArgumentError, "Invalid data -- must be a valid Ruby Hash or Array."
    end

    if not table_name.is_a? String
      raise ArgumentError, "Invalid table name: '#{$table}' -- must be a string."
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
