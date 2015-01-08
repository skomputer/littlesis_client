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
    end
  end

  describe "#get_entity_ids" do
    it_behaves_like "a single resource method", :list, :get_entity_ids

    context "when given a valid list id" do    
      it "should return an array of entity ids belonging to the list" do
        list = @client.list.get_with_entities(23, { num: 1000 })
        entity_ids = list.entities.map(&:id).map(&:to_i)
        results = @client.list.get_entity_ids(23)
        expect(entity_ids - results).to eq([])
        expect(results - entity_ids).to eq([])
      end
    end
  end

  describe "#get_network_links" do
    it_behaves_like "a single resource method", :list, :get_network_links

    it "should return an array of connections between entities in the list and related entities" do
      list = @client.list.get_with_entities(23, { num: 500 })
      entity_ids = list.entities.map(&:id).map(&:to_i)
      links = @client.list.get_network_links(23)
      expect(links.map do |l|
        val = entity_ids.include?(l[1]) and @client.relationship.between_entities(l[1], l[2], [l[3]]).count > 0
      end.uniq).to eq([true])
    end
  end
end