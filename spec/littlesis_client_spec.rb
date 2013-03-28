require 'littlesis_client'

describe LittlesisClient do
  before(:each) do
    @client = LittlesisClient.new("invalidkey", "api.littlesis.org")
  end
  
  context "when it has an invalid api key" do
    it "returns an authentication error" do
      expect { 
        @client.entity.get(1) 
      }.to raise_error(LittlesisClient::AuthenticationError)
    end
  end

  context "when it doesn't have an api key" do
    it "returns an authentication error" do
      @client.api_key = nil
      expect { 
        @client.entity.get(1) 
      }.to raise_error(LittlesisClient::AuthenticationError)
    end
  end
end