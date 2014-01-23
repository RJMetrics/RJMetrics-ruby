require 'rjmetrics-client/client'

VALID_CLIENT_ID = 12
VALID_API_KEY = "apiKey"
VALID_TIMEOUT = 5
SANDBOX_BASE = "https://sandbox-connect.rjmetrics.com/v2"

describe Client, "#new" do
  context "with valid arguments" do
    it "will create a RJMetricsClient" do

      expect(Client.new(VALID_CLIENT_ID, VALID_API_KEY, VALID_TIMEOUT).class).to eq(Client)
    end
  end

  context "with invalid arguments" do
    it "will raise an ArgumentError" do
      invalid_client_ids = [-1, 0, 10.1, "six", nil]
      invalid_api_keys = [10, nil]
      invalid_timeouts = [-1, 0, 5.6, "seven", nil]

      invalid_client_ids.map { |client_id| expect{ Client.new(client_id, VALID_API_KEY, VALID_TIMEOUT) }.to raise_error(ArgumentError) }
      invalid_api_keys.map { |api_key| expect{ Client.new(VALID_CLIENT_ID, api_key, VALID_TIMEOUT) }.to raise_error(ArgumentError) }
      invalid_timeouts.map { |timeout| expect{ Client.new(VALID_CLIENT_ID, VALID_API_KEY, timeout) }.to raise_error(ArgumentError) }
    end
  end
end

describe Client, "#authenticated" do
  context "with valid credentials" do
    it "will return true" do
      client = Client.new(VALID_CLIENT_ID, VALID_API_KEY, VALID_TIMEOUT)
      authenticate_table_name = "test"
      authenticate_data = JSON.parse("{\"keys\":[\"id\"],\"id\":1}")
      RestClient = double
      RestClient.stub(:post)

      RestClient.should_receive(:post).with(
        "#{SANDBOX_BASE}/client/#{VALID_CLIENT_ID}/table/#{authenticate_table_name}/data?apikey=#{VALID_API_KEY}",
        authenticate_data.to_json,
        {:content_type => :json,
          :accept => :json,
          :timeout => VALID_TIMEOUT}).and_return(true)

      client.authenticated?.should eq(true)
    end
  end
end
