# encoding: utf-8

require 'rspec'
require 'rjmetrics_client'
require 'rjmetrics-client/client'
require 'json'

describe RJMetrics::Client do

  let(:valid_client_id) { 12 }
  let(:valid_api_key) { "apiKey" }
  let(:valid_timeout) { 5 }
  let(:sandbox_base) { "https://sandbox-connect.rjmetrics.com/v2" }
  let(:api_base) { "https://connect.rjmetrics.com/v2" }

  let(:import_data_klass) do
    Class.new do
      include Comparable
      attr :n
      def initialize(n)
        @n = n
      end

      def succ
        self.class.new(@n + 1)
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

  describe "#new" do
    context "with valid arguments" do
      it "will create a RJMetricsClient" do
        expect(RJMetrics::Client.new(valid_client_id, valid_api_key, valid_timeout).class).to eq(RJMetrics::Client)
      end
    end

    context "with invalid arguments" do
      it "will raise an ArgumentError" do
        invalid_client_ids = [-1, 0, 10.1, "six", nil]
        invalid_api_keys = [10, nil]
        invalid_timeouts = [-1, 0, 5.6, "seven", nil]
        valid_timeout = RJMetrics::Client::DEFAULT_TIMEOUT_SECONDS

        invalid_client_ids.map { |client_id| expect{ RJMetrics::Client.new(client_id, valid_api_key, valid_timeout) }.to raise_error(ArgumentError) }
        invalid_api_keys.map { |api_key| expect{ RJMetrics::Client.new(valid_client_id, api_key, valid_timeout) }.to raise_error(ArgumentError) }
        invalid_timeouts.map { |timeout| expect{ RJMetrics::Client.new(valid_client_id, valid_api_key, timeout) }.to raise_error(ArgumentError) }
      end
    end
  end

  describe "#authenticated" do
    context "with valid credentials" do
      it "will return true" do
        client = RJMetrics::Client.new(valid_client_id, valid_api_key, valid_timeout)

        authenticate_table_name = "test"
        authenticate_data = Array.new(1, import_data_klass.new(1))

        expect(RestClient).to receive(:post)
        .with(
          "#{sandbox_base}/client/#{valid_client_id}/table/#{authenticate_table_name}/data?apikey=#{valid_api_key}",
          authenticate_data.to_json,
          {
            :content_type => :json,
            :accept => :json,
            :timeout => valid_timeout
          }
        )
        .and_return("{\"code:\" 200, \"message\": \"created\"}")

        client.authenticated?.should eq(true)
      end
    end
  end

  describe "#pushData" do
    context "with valid arguments" do
      let(:client) {RJMetrics::Client.new(valid_client_id, valid_api_key, valid_timeout)}
      let(:table_name) {"table"}

      let(:data) { (import_data_klass.new(1)..import_data_klass.new(number_of_data_points)).to_a }
      let(:number_of_data_points) { 3 }

      context "with less data points than the batch size" do
        it "will return a success response per data point" do
          expect(RestClient).to receive(:post)
          .with(
            "#{api_base}/client/#{valid_client_id}/table/#{table_name}/data?apikey=#{valid_api_key}",
            data.to_json,
              {
              :content_type => :json,
              :accept => :json,
              :timeout => valid_timeout
            }
          )
          .exactly(1).times
          .and_return({:code => 200, :message => "created"}.to_json)

          expect(client.pushData(table_name, data)).to eq(Array.new(1, {:code => 200, :message => "created"}.to_json))
        end
      end

      context "with more data points than the batch size" do
        let(:number_of_data_points) { RJMetrics::Client::BATCH_SIZE * 10 + 1 }
        it "will push data in batches" do
          expect(RestClient).to receive(:post)
          .with(
            "#{api_base}/client/#{valid_client_id}/table/#{table_name}/data?apikey=#{valid_api_key}",
            anything,
            {
              :content_type => :json,
              :accept => :json,
              :timeout => valid_timeout
            }
          )
          .exactly(11).times
          .and_return({:code => 200, :message => "created"}.to_json)


          expect(client.pushData(table_name, data)).to eq(Array.new(11, {:code => 200, :message => "created"}.to_json))
        end
      end

      context "when the server cuts the connection" do
        it "will raise an InvalidResponseException" do
          expect(RestClient).to receive(:post)
          .with(
            "#{api_base}/client/#{valid_client_id}/table/#{table_name}/data?apikey=#{valid_api_key}",
            data.to_json,
            {
              :content_type => :json,
              :accept => :json,
              :timeout => valid_timeout
            }
          )
          .and_raise(RestClient::ServerBrokeConnection.new)

          expect{client.pushData(table_name, data)}.to raise_error(RJMetrics::Client::InvalidResponseException)
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

        client = RJMetrics::Client.new(valid_client_id, valid_api_key)

        invalid_datas.map { |data_point| expect{ client.pushData(valid_table_name, data_point) }.to raise_error(ArgumentError) }
        invalid_table_names.map { |table_name| expect{ client.pushData(table_name, valid_data) }.to raise_error(ArgumentError) }
        invalid_urls.map { |url| expect{ client.pushData(valid_table_name, valid_data, url) }.to raise_error(ArgumentError) }
      end
    end
  end
end
