shared_examples_for "a single resource method" do |model, method_name|
  context "when given an invalid id" do      
    it "should return an invalid request error" do
      expect {
        @entity = @client.send(model).send(method_name, "thisisnotanid")
      }.to raise_error(LittlesisClient::InvalidRequestError)
    end
  end
end