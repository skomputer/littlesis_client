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
  
  describe "#categories" do
    it "should return an array of categories with ids" do
      @categories = @client.relationship.categories
      expect(@categories.collect { |c| c["id"].to_i }).to eq((1..10).to_a)
    end

    it "should return an array of categories with names" do
      @names = %w(Position Education Membership Family Donation Transaction Lobbying Social Professional Ownership) 
      @categories = @client.relationship.categories
      expect(@categories.collect { |c| c["name"] }).to eq(@names)
    end
  end
  
  describe "#get_many" do
    context "when given multiple relationship ids" do
      before(:each) do
        @ids = [74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95]
        @details = false
      end
      
      it "should return multiple relationships" do
        @rels = @client.relationship.get_many(@ids, @details)
        expect(@rels.count).to be > 1
        expect(@rels.collect { |e| e.class.name }.uniq).to eq(["LittlesisClient::Relationship"])
      end
      
      it "should return multiple valid relationships" do
        @rels = @client.relationship.get_many(@ids, @details)
        expect(@rels.map(&:valid?).uniq).to eq([true])      
      end

      it "should return relationships with the given ids" do
        @rels = @client.relationship.get_many(@ids, @details)
        expect(@rels.map(&:id).map(&:to_i) - @ids).to eq([])            
      end
      
      context "when given a details=true argument" do
        before(:each) do
          @details = true
          @rels = @client.relationship.get_many(@ids, @details)
        end
        
        it "should return executive details" do
          expect(@rels.collect { |r| r.details[:is_executive].to_i }.uniq - [0, 1]).to eq([])
        end

        it "should return board details" do
          expect(@rels.collect { |r| r.details[:is_board].to_i }.uniq - [0, 1]).to eq([])
        end
      end
      
      context "when given only invalid ids" do
        before(:each) do
          @ids = ["99999999999", "999999999999999", "9999999999999999999"]
        end
        
        it "should return an empty array" do
          @rels = @client.relationship.get_many(@ids, @details)
          expect(@rels).to eq([])
        end
      end
    end      
  end
  
  describe "#between_entities" do
    context "when given two valid and related entity ids" do
      before(:each) do
        @entity1_id = 1026
        @entity2_id = 1
        @cat_ids = nil
      end    
      
      it "should return multiple relationships" do
        @rels = @client.relationship.between_entities(@entity1_id, @entity2_id, @cat_ids)
        expect(@rels.count).to be > 1
        expect(@rels.collect { |e| e.class.name }.uniq).to eq(["LittlesisClient::Relationship"])
      end
      
      it "should return valid relationships" do
        @rels = @client.relationship.between_entities(@entity1_id, @entity2_id, @cat_ids)
        expect(@rels.map(&:valid?).uniq).to eq([true])      
      end
      
      it "should return relationships between the provided entities" do
        @rels = @client.relationship.between_entities(@entity1_id, @entity2_id, @cat_ids)
        expect(@rels.collect { |r| [r.entity1_id.to_i, r.entity2_id.to_i] }.flatten.uniq - [@entity1_id, @entity2_id]).to eq([])
      end      
      
      context "when limited to particular categories" do
        before(:each) do
          @ids = [1026, 1]
          @cat_ids = [1, 5]
        end
        
        it "should only return relationships with those categories" do
          @rels = @client.relationship.between_entities(@entity1_id, @entity2_id, @cat_ids)
          expect(@rels.map(&:category_id).map(&:to_i).uniq - @cat_ids).to eq([])
        end
      end
    end
  end 
end