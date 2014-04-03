require 'rspec'
require 'rjmetrics_client'
require 'rjmetrics-client/client'
require 'json'

VALID_CLIENT_ID = 12
VALID_API_KEY = "apiKey"

describe RJMetricsClient do
  describe "#new" do
    context "with improper credentials" do
      it "will raise an exception" do
        data = Array.new(1,RJMetrics::ImportData.new(1))
        table_name = "test"

        RestClient.should_receive(:post)
        .with(
          "#{RJMetrics::Client::SANDBOX_BASE}/client/#{VALID_CLIENT_ID}/table/#{table_name}/data?apikey=#{VALID_API_KEY}",
          data.to_json,
            {:content_type => :json,
              :accept => :json,
              :timeout => RJMetrics::Client::DEFAULT_TIMEOUT_SECONDS})
          .and_raise(RestClient::Exception.new({:code => 500, :message => "Server Error", :reasons => "Something went wrong on RJMetrics' end."}.to_json, 500))

        expect{ RJMetricsClient.new(VALID_CLIENT_ID, VALID_API_KEY) }.to raise_error(RJMetrics::Client::UnableToConnectException)
      end
    end
  end
end

describe RJMetrics::Client do

  describe "#new" do
    context "with valid arguments" do
      it "will create a RJMetricsClient" do
        expect(RJMetrics::Client.new(VALID_CLIENT_ID, VALID_API_KEY, RJMetrics::Client::DEFAULT_TIMEOUT_SECONDS).class).to eq(RJMetrics::Client)
      end
    end

    context "with invalid arguments" do
      it "will raise an ArgumentError" do
        invalid_client_ids = [-1, 0, 10.1, "six", nil]
        invalid_api_keys = [10, nil]
        invalid_timeouts = [-1, 0, 5.6, "seven", nil]
        valid_timeout = RJMetrics::Client::DEFAULT_TIMEOUT_SECONDS

        invalid_client_ids.map { |client_id| expect{ RJMetrics::Client.new(client_id, VALID_API_KEY, valid_timeout) }.to raise_error(ArgumentError) }
        invalid_api_keys.map { |api_key| expect{ RJMetrics::Client.new(VALID_CLIENT_ID, api_key, valid_timeout) }.to raise_error(ArgumentError) }
        invalid_timeouts.map { |timeout| expect{ RJMetrics::Client.new(VALID_CLIENT_ID, VALID_API_KEY, timeout) }.to raise_error(ArgumentError) }

      end
    end

    describe "#authenticated" do
      context "with valid credentials" do
        it "will return true" do
          client = RJMetrics::Client.new(VALID_CLIENT_ID, VALID_API_KEY, RJMetrics::Client::DEFAULT_TIMEOUT_SECONDS)

          authenticate_table_name = "test"
          authenticate_data = Array.new(1, RJMetrics::ImportData.new(1))

          RestClient.should_receive(:post)
          .with(
            "#{RJMetrics::Client::SANDBOX_BASE}/client/#{VALID_CLIENT_ID}/table/#{authenticate_table_name}/data?apikey=#{VALID_API_KEY}",
            authenticate_data.to_json,
              {:content_type => :json,
                :accept => :json,
                :timeout => RJMetrics::Client::DEFAULT_TIMEOUT_SECONDS})
            .and_return("{\"code:\" 200, \"message\": \"created\"}")

            client.authenticated?.should eq(true)
        end
      end
    end

    describe "#pushData" do
      context "with valid arguments" do
        before(:each) do
          @client = RJMetrics::Client.new(VALID_CLIENT_ID, VALID_API_KEY, RJMetrics::Client::DEFAULT_TIMEOUT_SECONDS)
          @table_name = "table"
        end

        it "will return a success response per data point" do
          data = (RJMetrics::ImportData.new(1)..RJMetrics::ImportData.new(3)).to_a

          RestClient.should_receive(:post)
          .with(
            "#{RJMetrics::Client::API_BASE}/client/#{VALID_CLIENT_ID}/table/#{@table_name}/data?apikey=#{VALID_API_KEY}",
            data.to_json,
              {:content_type => :json,
                :accept => :json,
                :timeout => RJMetrics::Client::DEFAULT_TIMEOUT_SECONDS})
            .exactly(1).times
            .and_return({:code => 200, :message => "created"}.to_json)

            @client.pushData(@table_name, data).should eq(Array.new(1, {:code => 200, :message => "created"}.to_json))
        end

        it "will push data in batches" do
          number_of_data_points = RJMetrics::Client::BATCH_SIZE * 10 + 1
          data = (RJMetrics::ImportData.new(1)..RJMetrics::ImportData.new(number_of_data_points)).to_a

          RestClient.should_receive(:post)
          .with(
            "#{RJMetrics::Client::API_BASE}/client/#{VALID_CLIENT_ID}/table/#{@table_name}/data?apikey=#{VALID_API_KEY}",
            anything,
              {:content_type => :json,
                :accept => :json,
                :timeout => RJMetrics::Client::DEFAULT_TIMEOUT_SECONDS})
            .exactly(11).times
            .and_return({:code => 200, :message => "created"}.to_json)


            @client.pushData(@table_name, data).should eq(Array.new(11, {:code => 200, :message => "created"}.to_json))
        end

        context "with server error" do
          it "it will raise an exception" do
            data = (RJMetrics::ImportData.new(1)..RJMetrics::ImportData.new(3)).to_a

            RestClient.should_receive(:post)
            .with(
              "#{RJMetrics::Client::API_BASE}/client/#{VALID_CLIENT_ID}/table/#{@table_name}/data?apikey=#{VALID_API_KEY}",
              data.to_json,
                {:content_type => :json,
                  :accept => :json,
                  :timeout => RJMetrics::Client::DEFAULT_TIMEOUT_SECONDS})
              .and_raise(RestClient::Exception.new({:code => 500, :message => "Server Error", :reasons => "Something went wrong on RJMetrics' end."}.to_json, 500))

              expect { @client.pushData(@table_name, data) }.to raise_error(RJMetrics::Client::InvalidRequestException)
          end
        end
      end
    end

    context "with invalid arguments" do
      it "will return raise an Error" do
        valid_data = {:keys => [:id], :id => 1}
        invalid_datas = ["string", 5, nil]
        valid_table_name = "table"
        invalid_table_names = [["name"], 5, {:name => "table_name"}, nil]
        invalid_urls = [5, ["url"], {:url => "url"}]

        client = RJMetrics::Client.new(VALID_CLIENT_ID, VALID_API_KEY)

        invalid_datas.map { |data_point| expect{ client.pushData(valid_table_name, data_point) }.to raise_error(ArgumentError) }
        invalid_table_names.map { |table_name| expect{ client.pushData(table_name, valid_data) }.to raise_error(ArgumentError) }
        invalid_urls.map { |url| expect{ client.pushData(valid_table_name, valid_data, url) }.to raise_error(ArgumentError) }
      end
    end
  end
end

module RJMetrics
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
end
