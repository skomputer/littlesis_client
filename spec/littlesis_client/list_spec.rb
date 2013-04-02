require 'littlesis_client'
require 'shared_examples'

describe LittlesisClient::List do
  let(:api_key) { ENV["API_KEY"] }

  before(:each) do
    @client = LittlesisClient.new(api_key, "api.littlesis.org")
  end

  describe "#get" do
    it_behaves_like "a single resource method", :list, :get

    context "when given a valid list id" do
      before(:each) do
        @list = @client.list.get(23)
      end

      it "should return a list object" do
        expect(@list.class.name).to eq("LittlesisClient::List")
      end
      
      it "should return a valid object" do
        expect(@list.valid?).to eq(true)
      end      
    end    
  end
  
  describe "#get_with_entities" do
    it_behaves_like "a single resource method", :list, :get_with_entities

    context "when given a valid list id" do
      before(:each) do
        @options = {}
        @type_ids = nil
      end
    
      it "should return a list object" do
        @list = @client.list.get_with_entities(23, @options)
        expect(@list.class.name).to eq("LittlesisClient::List")
      end
      
      it "should return a valid object" do
        @list = @client.list.get_with_entities(23, @options)
        expect(@list.valid?).to eq(true)
      end
      
      it "should return a list with an array of entities" do
        @list = @client.list.get_with_entities(23, @options)
        expect(@list.entities.collect { |e| e.class.name }.uniq).to eq(["LittlesisClient::Entity"])
      end

      context "when given specific entity types" do
        before(:each) do
          @type_ids = [29]
          @types = @client.entity.type_names(@type_ids)
          @options = { :type_ids => @type_ids.join(","), :num => 20 }
        end
        
        it "should only return entities with those types" do
          @list = @client.list.get_with_entities(23, @options)
          @entity_ids = @list.entities.map(&:id)
          @entities = @client.entity.get_many(@entity_ids, true)
          expect(@entities.collect { |e| e.details[:types] & @types }.uniq).to eq([@types])
        end
      end
    end
  end
end