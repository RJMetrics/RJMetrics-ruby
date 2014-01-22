class Client

 API_BASE = "https://connect.rjmetrics.com/v2"
 SANDBOX_BASE = "https://sandbox-connect.rjmetrics.com/v2"

  def initialize(client_id, api_key, timeout_in_seconds)
    if not client_id.integer? or client_id <= 0
      raise ArgumentError, "Invalid client ID: #{client_id} -- must be a positive integer."
    end

    if not timeout_in_seconds.integer? or timeout_in_seconds <= 0
      raise ArgumentError, "Invalid timeout: #{timeout_in_seconds} -- must be a positive integer."
    end

    if not api_key.is_a? String
      raise ArgumentError, "Invalid API key: #{timeout_in_seconds} -- must be a string."
    end
  end

  def hi
    puts "Hello World From CLient"
    puts API_BASE
    puts SANDBOX_BASE
  end

  class UnableToConnectException < RuntimeError
  end
  class InvalidRequestException < RuntimeError
  end
end
