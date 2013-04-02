require 'littlesis_client'
require 'shared_examples'

describe LittlesisClient::Entity do
  let(:api_key) { ENV["API_KEY"] }

  before(:each) do
    @client = LittlesisClient.new(api_key, "api.littlesis.org")
  end

  describe "#get" do
    it_behaves_like "a single resource method", :entity, :get

    context "when given a valid entity id" do
      before(:each) do
        @entity = @client.entity.get(1)
      end

      it "should return an entity object" do
        expect(@entity.class.name).to eq("LittlesisClient::Entity")
      end
      
      it "should return a valid entity" do
        expect(@entity.valid?).to eq(true)
      end
    end    
  end
  
  describe "#get_with_details" do
    it_behaves_like "a single resource method", :entity, :get_with_details

    context "when given a valid entity id" do
      before(:each) do
        @entity = @client.entity.get_with_details(1)
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
  end
  
  describe "#get_many" do
    context "when given multiple entity ids" do
      before(:each) do
        @ids = [1, 2, 3, 1201, 28219, 35306]
        @details = false
      end
      
      it "should return multiple entities" do
        @entities = @client.entity.get_many(@ids, @details)
        expect(@entities.count).to be > 1
        expect(@entities.collect { |e| e.class.name }.uniq).to eq(["LittlesisClient::Entity"])
      end
      
      it "should return multiple valid entities" do
        @entities = @client.entity.get_many(@ids, @details)
        expect(@entities.collect { |e| e.valid? }.uniq).to eq([true])      
      end

      it "should return entities with the given ids" do
        @entities = @client.entity.get_many(@ids, @details)
        expect(@entities.map(&:id).map(&:to_i) - @ids).to eq([])            
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
    it_behaves_like "a single resource method", :entity, :get_with_relationships

    context "when given a valid entity id" do
      before(:each) do
        @id = 1
        @options = {}
      end
      
      it "should return multiple relationships" do
        @relationships = @client.entity.get_with_relationships(@id, @options).relationships
        expect(@relationships.count).to be > 0
        expect(@relationships.collect { |r| r.class.name }.uniq).to eq(["LittlesisClient::Relationship"])
      end
      
      it "should return multiple valid relationships" do
        @relationships = @client.entity.get_with_relationships(@id, @options).relationships
        expect(@relationships.collect(&:valid?).uniq).to eq([true])      
      end
      
      context "when given a limit of 10" do
        before(:each) do
          @options[:num] = 10
        end

        it "should return no more than 10 relationships" do
          @relationships = @client.entity.get_with_relationships(@id, @options).relationships
          expect(@relationships.count).to be <= 10        
        end
      end
      
      context "when given category ids" do
        before(:each) do
          @options[:cat_ids] = "1,2"
        end
        
        it "should only return relationships with those category ids" do
          @relationships = @client.entity.get_with_relationships(@id, @options).relationships          
          expect(@relationships.map(&:category_id).map(&:to_i).uniq - [1, 2]).to eq([])
        end
      end
      
      context "when given an order" do
        before(:each) do
          @options[:order] = 1
        end
        
        it "should only return relationships where the entity is first" do
          @relationships = @client.entity.get_with_relationships(@id, @options).relationships          
          expect(@relationships.map(&:entity1_id).map(&:to_i).uniq).to eq([@id])
        end
      end
    end
  end
  
  describe "#get_related_entities" do
    it_behaves_like "a single resource method", :entity, :get_related_entities  

    context "when given a valid entity id" do
      before(:each) do
        @id = 1
        @options = {}
      end
      
      it "should return multiple entities" do
        @entities = @client.entity.get_related_entities(@id, @options)
        expect(@entities.count).to be > 0
        expect(@entities.collect { |e| e.class.name }.uniq).to eq(["LittlesisClient::Entity"])
      end
      
      it "should return multiple valid entities" do
        @entities = @client.entity.get_related_entities(@id, @options)
        expect(@entities.collect(&:valid?).uniq).to eq([true])      
      end
      
      it "should return the connecting relationships for each entity" do
        @entities = @client.entity.get_related_entities(@id, @options)
        expect(@entities.collect { |e| e.relationships.count }.uniq).not_to include(0)
        expect(@entities.collect { |e| e.relationships.collect { |r| r.class.name } }.flatten.uniq).to eq(["LittlesisClient::Relationship"])
      end

      context "when given a limit of 10" do
        before(:each) do
          @options[:num] = 10
        end

        it "should return no more than 10 entities" do
          @entities = @client.entity.get_related_entities(@id, @options)
          expect(@entities.count).to be <= 10        
        end
      end
      
      context "when given category ids" do
        before(:each) do
          @options[:cat_ids] = "1,2"
        end
        
        it "should only return entities connected by relationships with those category ids" do
          @entities = @client.entity.get_related_entities(@id, @options)
          expect(@entities.collect { |e| e.relationships.map(&:category_id).map(&:to_i) }.flatten.uniq - [1, 2]).to eq([])
        end
      end
      
      context "when given an order" do
        before(:each) do
          @options[:order] = 1
        end
        
        it "should only return entities connected by relationships where the entity is first" do
          @entities = @client.entity.get_related_entities(@id, @options)
          expect(@entities.collect { |e| e.relationships.map(&:entity1_id).map(&:to_i) }.flatten.uniq).to eq([@id])
        end
      end
      
      context "when limited to current relationships" do
        before(:each) do
          @options[:is_current] = 1
        end

        it "should only return entities connected by current relationships" do
          @entities = @client.entity.get_related_entities(@id, @options)
          expect(@entities.collect { |e| e.relationships.map(&:is_current).map(&:to_i) }.flatten.uniq).to eq([@id])
        end
      end      
    end
  
    describe "#get_related_entities_by_category" do
      it_behaves_like "a single resource method", :entity, :get_related_entities_by_category  

      before(:each) do
        @id = 1
        @options = {}
      end
      
      it "should return a hash of category ids with an array of related entities connected by relationships with that category" do
        @hash = @client.entity.get_related_entities_by_category(@id, @options)
        expect(@hash.map do |cat, entities| 
          entities.map do |e| 
            e.relationships.map(&:category_id).map(&:to_i)
          end.flatten.uniq == [cat]
        end.uniq).to eq([true])
      end
    end 
    
    describe "#get_leadership" do
      it_behaves_like "a single resource method", :entity, :get_leadership  
      
      before(:each) do
        @id = 1
        @options = {}
      end
      
      it "should return an array of entities with Person as their primary type" do
        @entities = @client.entity.get_leadership(@id, @options)
        expect(@entities.collect.map(&:primary_type).uniq).to eq(["Person"])
      end

      pending "should return an array of entities connected by board or executive relationships" do
        @entities = @client.entity.get_leadership(@id, @options)
      end
    end

    describe "#get_orgs" do
      it_behaves_like "a single resource method", :entity, :get_orgs  
      
      before(:each) do
        @id = 1164
        @options = {}
      end
      
      it "should return an array of entities with Org as their primary type" do
        @entities = @client.entity.get_orgs(@id, @options)
        expect(@entities.collect.map(&:primary_type).uniq).to eq(["Org"])
      end

      pending "should return an array of entities connected by board or executive relationships" do
        @entities = @client.entity.get_leadership(@id, @options)
      end
    end
    
    describe "#get_second_degree_entities" do
      it_behaves_like "a single resource method", :entity, :get_second_degree_entities  

      before(:each) do
        @id = 1
        @options = {}
      end
      
      it "should return no more than 20 entities with degree1_ids" do
        @entities = @client.entity.get_second_degree_entities(@id, @options)
        expect(@entities.count).to be <= 20
        expect(@entities.collect { |e| e.details[:degree1_ids] } & ["", nil]).to eq([])
      end
      
      context "when given a limit" do
        before(:each) do
          @limit = 10
          @options[:num] = @limit
        end
        
        it "should return no more entities than the limit" do
          @entities = @client.entity.get_second_degree_entities(@id, @options)
          expect(@entities.count).to be <= @limit
        end
      end
      
      context "when given a page number" do
        it "should return entities that aren't on other pages" do
          @entities1 = @client.entity.get_second_degree_entities(@id, { :page => 1 })
          @entities2 = @client.entity.get_second_degree_entities(@id, { :page => 2 })
          expect(@entities1.map(&:id) & @entities2.map(&:id)).to eq([])
        end
      end
      
      pending "when given category id options" do      
      end
      
      pending "when given order options" do      
      end
    end
  end

  describe "types" do
    it "should return an array of types with ids 1 to 36" do
      @types = @client.entity.types
      expect(@types.collect { |t| t["id"].to_i }).to eq((1..36).to_a)
    end

    it "should return an array of types with names" do
      @names = %w(Person Org PoliticalCandidate ElectedRepresentative Business GovernmentBody School MembershipOrg Philanthropy NonProfit PoliticalFundraising PrivateCompany PublicCompany IndustryTrade LawFirm LobbyingFirm PublicRelationsFirm IndividualCampaignCommittee Pac OtherCampaignCommittee MediaOrg ThinkTank Cultural SocialClub ProfessionalAssociation PoliticalParty LaborUnion Gse BusinessPerson Lobbyist Academic MediaPersonality ConsultingFirm PublicIntellectual PublicOfficial Lawyer)
      @types = @client.entity.types
      expect(@types.collect { |t| t["name"] }).to eq(@names)
    end  
  end
  
  describe "#type_names" do
    context "when given an array of type ids" do
      before(:each) do
        @type_ids = [1, 4, 9, 16]
        @names = %w(Person ElectedRepresentative Philanthropy LobbyingFirm)
      end
    
      it "should return an array of names for those types" do
        expect(@client.entity.type_names(@type_ids)).to eq(@names)
      end
    end
  end
end