class Client

 API_BASE = "https://connect.rjmetrics.com/v2"
 SANDBOX_BASE = "https://sandbox-connect.rjmetrics.com/v2"

  def initialize(client_id, api_key, timeout_in_seconds = 10)
    @client_id = client_id
    @api_key = api_key
    @timeout_in_seconds = timeout_in_seconds
    validateArgs
  end

  private

  def validateArgs
    if not @client_id.is_a? Integer or @client_id <= 0
      raise ArgumentError, "Invalid client ID: #{@client_id} -- must be a positive integer."
    end

    if not @timeout_in_seconds.is_a? Integer or @timeout_in_seconds <= 0
      raise ArgumentError, "Invalid timeout: #{@timeout_in_seconds} -- must be a positive integer."
    end

    if not @api_key.is_a? String
      raise ArgumentError, "Invalid API key: #{@timeout_in_seconds} -- must be a string."
    end
  end

  class UnableToConnectException < RuntimeError
  end
  class InvalidRequestException < RuntimeError
  end
end
