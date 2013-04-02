require 'littlesis_client'
require 'shared_examples'

describe LittlesisClient::Relationship do
  let(:api_key) { ENV["API_KEY"] }

  before(:each) do
    @client = LittlesisClient.new(api_key, "api.littlesis.org")
  end

  describe "#get" do
    it_behaves_like "a single resource method", :relationship, :get

    context "when given a valid relationship id" do
      before(:each) do
        @rel = @client.relationship.get(23)
      end

      it "should return an relationship object" do
        expect(@rel.class.name).to eq("LittlesisClient::Relationship")
      end
      
      it "should return a valid object" do
        expect(@rel.valid?).to eq(true)
      end
      
      it "should return a valid entity1" do
        expect(@rel.entity1.valid?).to eq(true)
      end

      it "should return a valid entity2" do
        expect(@rel.entity2.valid?).to eq(true)
      end
      
      it "should return an entity1 matching entity1_id" do
        expect(@rel.entity1.id).to eq(@rel.entity1_id)
      end

      it "should return an entity2 matching entity2_id" do
        expect(@rel.entity2.id).to eq(@rel.entity2_id)
      end
    end    
  end
  
  describe "#get_with_details" do
    it_behaves_like "a single resource method", :relationship, :get_with_details
  
    context "when given a valid relationship id" do
      before(:each) do
        @rel = @client.relationship.get_with_details(23)
      end

      it "should return a relationship object" do
        expect(@rel.class.name).to eq("LittlesisClient::Relationship")      
      end

      it "should return a valid object" do
        expect(@rel.valid?).to eq(true)
      end
      
      it "should return a valid entity1" do
        expect(@rel.entity1.valid?).to eq(true)
      end

      it "should return a valid entity2" do
        expect(@rel.entity2.valid?).to eq(true)
      end
      
      it "should return an entity1 matching entity1_id" do
        expect(@rel.entity1.id).to eq(@rel.entity1_id)
      end

      it "should return an entity2 matching entity2_id" do
        expect(@rel.entity2.id).to eq(@rel.entity2_id)
      end
      
      it "should return executive details" do
        expect([0, 1]).to include(@rel.details[:is_executive].to_i)
      end

      it "should return board details" do
        expect([0, 1]).to include(@rel.details[:is_board].to_i)
      end
    end
  end
end