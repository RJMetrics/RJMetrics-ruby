require 'rspec'
require 'rjmetrics-client/client'
require 'json'

VALID_CLIENT_ID = 12
VALID_API_KEY = "apiKey"
VALID_TIMEOUT = 5
SANDBOX_BASE = "https://sandbox-connect.rjmetrics.com/v2"
API_BASE = "https://connect.rjmetrics.com/v2"


describe Client do

  before(:each) do
    RestClient = double.stub(:post)
  end

  describe "#new" do
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

  describe "#authenticated" do
    context "with valid credentials" do
      it "will return true" do
        client = Client.new(VALID_CLIENT_ID, VALID_API_KEY, VALID_TIMEOUT)

        authenticate_table_name = "test"
        authenticate_data = Array.new(1, ImportData.new(1))

        RestClient.should_receive(:post)
        .with(
          "#{SANDBOX_BASE}/client/#{VALID_CLIENT_ID}/table/#{authenticate_table_name}/data?apikey=#{VALID_API_KEY}",
          authenticate_data.to_json,
          {:content_type => :json,
            :accept => :json,
            :timeout => VALID_TIMEOUT})
          .and_return("{\"code:\" 200, \"message\": \"created\"}")

        client.authenticated?.should eq(true)
      end
    end
  end

  describe "#pushData" do
    context "with valid arguments" do
      before(:each) do
        @client = Client.new(VALID_CLIENT_ID, VALID_API_KEY, VALID_TIMEOUT)
        @table_name = "table"
      end

      it "will return a success response per data point" do
        data = (ImportData.new(1)..ImportData.new(3)).to_a

        RestClient.should_receive(:post)
        .with(
          "#{API_BASE}/client/#{VALID_CLIENT_ID}/table/#{@table_name}/data?apikey=#{VALID_API_KEY}",
          data.to_json,
          {:content_type => :json,
            :accept => :json,
            :timeout => VALID_TIMEOUT})
          .exactly(1).times
          .and_return({:code => 200, :message => "created"}.to_json)

        @client.pushData(@table_name, data).should eq(Array.new(1, {:code => 200, :message => "created"}.to_json))
      end

      it "will push data in batches of 100" do
        number_of_data_points = 100 * 10 + 1
        data = (ImportData.new(1)..ImportData.new(number_of_data_points)).to_a

        RestClient.should_receive(:post)
        .with(
          "#{API_BASE}/client/#{VALID_CLIENT_ID}/table/#{@table_name}/data?apikey=#{VALID_API_KEY}",
          anything,
          {:content_type => :json,
            :accept => :json,
            :timeout => VALID_TIMEOUT})
          .exactly(11).times
          .and_return({:code => 200, :message => "created"}.to_json)


        @client.pushData(@table_name, data).should eq(Array.new(11, {:code => 200, :message => "created"}.to_json))
      end
    end

    context "with invalid arguments" do
      it "will return raise an Error" do
        valid_data = {:keys => [:id], :id => 1}
        invalid_datas = ["string", 5, nil]
        valid_table_name = "table"
        invalid_table_names = [["name"], 5, {:name => "table_name"}, nil]
        invalid_urls = [5, ["url"], {:url => "url"}]

        client = Client.new(VALID_CLIENT_ID, VALID_API_KEY)

        invalid_datas.map { |data_point| expect{ client.pushData(valid_table_name, data_point) }.to raise_error(ArgumentError) }
        invalid_table_names.map { |table_name| expect{ client.pushData(table_name, valid_data) }.to raise_error(ArgumentError) }
        invalid_urls.map { |url| expect{ client.pushData(valid_table_name, valid_data, url) }.to raise_error(ArgumentError) }
      end
    end
  end
end

class ImportData
  include Comparable
  attr :n
  def initialize(n)
    @n = n
  end

  def succ
    ImportData.new(@n + 1)
  end

  def to_s
    self.inspect.to_s
  end

  def <=>(other)
    @n <=> other.n
  end

  def inspect
    {:keys => [:id], :id => @n}
  end

  def to_json(options = nil)
    self.inspect.to_json(options)
  end
end
