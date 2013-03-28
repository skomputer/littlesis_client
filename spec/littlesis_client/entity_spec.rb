require 'littlesis_client'

shared_examples_for "a model method" do |model, method_name|
  context "when given an invalid id" do      
    it "should return an invalid request error" do
      expect {
        @entity = @client.send(model).send(method_name, "thisisnotanid")
      }.to raise_error(LittlesisClient::InvalidRequestError)
    end
  end
end


describe LittlesisClient::Entity do
  let(:api_key) { ENV["API_KEY"] }

  before(:each) do
    @client = LittlesisClient.new(api_key, "api.littlesis.org")
  end

  describe "#get" do
    context "when given a valid entity id" do
      before(:each) do
        @entity = @client.entity.get(1)
      end

      it "should return an entity object" do
        expect(@entity.class.name).to eq("LittlesisClient::Entity")
      end
      
      it "should return a valid object" do
        expect(@entity.valid?).to eq(true)
      end
    end
    
    it_behaves_like "a model method", :entity, :get
  end
  
  describe "#details" do
    context "when given a valid entity id" do
      before(:each) do
        @entity = @client.entity.details(1)
      end

      it "should return an entity object" do
        expect(@entity.class.name).to eq("LittlesisClient::Entity")
      end
      
      it "should return a valid entity" do
        expect(@entity.valid?).to eq(true)
      end
      
      it "should return an entity with types" do
        expect(@entity.details[:types].count).to be > 0
      end      

      it "should return an entity with aliases" do
        expect(@entity.details[:Aliases].count).to be > 0
      end      
    end

    it_behaves_like "a model method", :entity, :details
  end
  
  describe "#get_many" do
    context "when given multiple entity ids" do
      before(:each) do
        @ids = [1, 2, 3, 1201, 28219, 35306]
        @details = false
      end
      
      it "should return multiple entities" do
        @entities = @client.entity.get_many(@ids, @details)
        expect(@entities.count).to be > 0
        expect(@entities.collect { |e| e.class.name }.uniq).to eq(["LittlesisClient::Entity"])
      end
      
      it "should return multiple valid entities" do
        @entities = @client.entity.get_many(@ids, @details)
        expect(@entities.collect { |e| e.valid? }.uniq).to eq([true])      
      end
      
      context "when given a details=true argument" do
        before(:each) do
          @details = true
        end
      
        it "should return multiple entities with types" do
          @entities = @client.entity.get_many(@ids, @details)
          expect(@entities.collect { |e| e.details[:types].count }.uniq).not_to include(0)
        end        
      end
      
      context "when given only invalid ids" do
        before(:each) do
          @ids = ["99999999999", "999999999999999", "9999999999999999999"]
        end
        
        it "should return an empty array" do
          @entities = @client.entity.get_many(@ids, @details)
          expect(@entities).to eq([])        
        end
      end
    end      
  end

  describe "#get_with_relationships" do
    context "when given a valid entity id" do
      before(:each) do
        @relationships = @client.entity.get_with_relationships(1).relationships
      end
      
      it "should return multiple relationships" do
        expect(@relationships.count).to be > 0
        expect(@relationships.collect { |r| r.class.name }.uniq).to eq(["LittlesisClient::Relationship"])
      end
      
      it "should return multiple valid relationships" do
        expect(@relationships.collect { |r| r.valid? }.uniq).to eq([true])      
      end      
    end
  
    it_behaves_like "a model method", :entity, :get_with_relationships
  end
  
  describe "#get_with_related_entities" do
    context "when given a valid entity id" do
      before(:each) do
        @entities = @client.entity.get_with_related_entities(1).related_entities
      end
      
      it "should return multiple entities" do
        expect(@entities.count).to be > 0
        expect(@entities.collect { |e| e.class.name }.uniq).to eq(["LittlesisClient::Entity"])
      end
      
      it "should return multiple valid entities" do
        expect(@entities.collect { |e| e.valid? }.uniq).to eq([true])      
      end
      
      it "should return the connecting relationships for each entity" do
        expect(@entities.collect { |e| e.relationships.count }.uniq).not_to include(0)
        expect(@entities.collect { |e| e.relationships.collect { |r| r.class.name } }.flatten.uniq).to eq(["LittlesisClient::Relationship"])
      end      
    end
  
    it_behaves_like "a model method", :entity, :get_with_related_entities  
  end
end