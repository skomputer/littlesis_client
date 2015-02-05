require 'littlesis_client'
require 'shared_examples'

describe LittlesisClient::Entity do
  let(:api_key) { ENV["API_KEY"] }

  before(:each) do
    @client = LittlesisClient.new(api_key, (ENV['API_HOST'] or "api.littlesis.org"))
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
  end

  describe "#get_relationships_with_related_entities" do
    it_behaves_like "a single resource method", :entity, :get_related_entities_by_category  

    before(:each) do
      @id = 1
      @options = {}
    end
    
    it "should return an array of relationships with related entities" do
      @relationships = @client.entity.get_relationships_with_related_entities(@id, @options)
      expect(@relationships.map do |rel| 
        (rel.entity1_id == @id.to_s and rel.entity2_id == rel.entity2.id) or (rel.entity2_id == @id.to_s and rel.entity1_id == rel.entity1.id)
      end.uniq).to eq([true])
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

    it "should return an array of entities connected by board or executive relationships" do
      @entities = @client.entity.get_leadership(@id, @options)
      expect(@entities.collect do |e|
        @client.relationship.between_entities(@id, e.id, [1]).collect do |r|
          rel = @client.relationship.get_with_details(r.id)
          [rel.details[:is_board].to_i, rel.details[:is_executive].to_i]
        end.flatten.include? 1
      end.uniq).to eq([true])
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

    it "should return an array of entities connected by board or executive relationships" do
      @entities = @client.entity.get_orgs(@id, @options)
      expect(@entities.collect do |e|
        @client.relationship.between_entities(@id, e.id, [1]).collect do |r|
          rel = @client.relationship.get_with_details(r.id)
          [rel.details[:is_board].to_i, rel.details[:is_executive].to_i]
        end.flatten.include? 1
      end.uniq).to eq([true])
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
      expect(@entities.collect { |e| e.details[:degree1_ids].split(",").empty? }.uniq).to eq([false])
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
    
    context "when given category id options" do      
      before(:each) do
        # interlocks for council on foreign relations via membership
        @id = 33271
        @cat_ids = [3]
        @options[:cat1_ids] = @cat_ids.join(",")
        @options[:cat2_ids] = @cat_ids.join(",")
      end
      
      it "should return entities that are only connected by relationships with the given categories" do
        @entities = @client.entity.get_second_degree_entities(@id, @options)
        expect(@entities.collect do |e|
          e.details[:degree1_ids].split(",").collect do |degree1_id|
            [@client.relationship.between_entities(degree1_id, @id, @cat_ids).count, 
             @client.relationship.between_entities(degree1_id, e.id, @cat_ids).count]
          end.flatten.include? 0
        end.uniq).to eq([false])
      end
    end
    
    context "when given order options" do      
      before(:each) do
        # recipients of donations from people with positions in Fix the Debt
        @id = 103280
        @options[:cat1_ids] = 1
        @options[:cat2_ids] = 5
        @options[:order1] = 2
        @options[:order2] = 1
      end
      
      it "should return entities that are only connected by relationships pointing in the proper direction" do        
        @entities = @client.entity.get_second_degree_entities(@id, @options)
        expect(@entities.take(5).collect do |e|
          e.details[:degree1_ids].split(",").take(5).collect do |degree1_id|
            options1 = { :cat_ids => @options[:cat1_ids], :order => @options[:order1] }
            options2 = { :cat_ids => @options[:cat2_ids], :order => @options[:order2] }
            [@client.entity.get_related_entities(@id, options1).map(&:id).map(&:to_i).include?(degree1_id.to_i),
             @client.entity.get_related_entities(degree1_id, options2).map(&:id).map(&:to_i).include?(e.id.to_i)]
          end
        end.flatten.uniq).to eq([true])          
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
  
  describe "#get_lists" do
    it_behaves_like "a single resource method", :entity, :get_lists 

    context "when given a valid entity id" do
      before(:each) do
        @id = 1164
        @lists = @client.entity.get_lists(@id)
      end
      
      it "should return an array of lists" do
        expect(@lists.collect { |l| l.class.name }.uniq).to eq(["LittlesisClient::List"])
      end
      
      it "should return valid lists" do
        expect(@lists.collect(&:valid?).uniq).to eq([true])
      end
    end    
  end
  
  describe "#get_images" do
    it_behaves_like "a single resource method", :entity, :get_images 
    
    context "when given a valid entity id" do
      before(:each) do
        @id = 14597
        @images = @client.entity.get_images(@id)
      end
      
      it "should return an array of imags" do
        expect(@images.collect { |l| l.class.name }.uniq).to eq(["LittlesisClient::Image"])      
      end
      
      it "should return valid images" do
        expect(@images.collect(&:valid?).uniq).to eq([true])
      end
    end      
  end

  describe "#get_featured_image_url" do
    it_behaves_like "a single resource method", :entity, :get_featured_image_url
    
    context "when given a valid entity id with a featured image" do
      before(:each) do
        @id = 14597
        @url = @client.entity.get_featured_image_url(@id)
      end

      it "should return a featured image_url" do
        expect(@url).to match(/images\/profile/)
      end
    end

    context "when given a valid person id without a featured image" do
      before(:each) do
        @id = 171446
        @url = @client.entity.get_featured_image_url(@id)
      end

      it "should return a default person image" do
        expect(@url).to eq(LittlesisClient::Image::DEFAULT_IMAGE_PATH + "anon.png")
      end
    end
  end

  describe "#get_political" do
    it_behaves_like "a single resource method", :entity, :get_political

    context "when given a valid entity id with political contributions" do
      before(:each) do
        @id = 1164
        @data = @client.entity.get_political(@id)
      end

      it "should return person and org recipients" do
        expect(@data['person_recipients'].count).to be > 0
        expect(@data['org_recipients'].count).to be > 0
      end

      it "should return a donor matching the entity" do
        expect(@data['donors'].keys).to eq([@id.to_s])
      end

      it "should return consistent democratic, republican, and other party totals" do
        all_recipients = @data['person_recipients'].values.concat(@data['org_recipients'].values)
        dem_total = all_recipients.select { |r| r['party'] == 'D' }.map { |r| r['amount'] }.inject(0, :+)
        rep_total = all_recipients.select { |r| r['party'] == 'R' }.map { |r| r['amount'] }.inject(0, :+)
        other_total = all_recipients.select { |r| !['R', 'D'].include?(r['party']) }.map { |r| r['amount'] }.inject(0, :+)
        expect(@data['dem_total']).to eq(dem_total)
        expect(@data['rep_total']).to eq(rep_total)
        expect(@data['other_total']).to eq(other_total)
      end
    end
  end
  
  describe "#search" do
    context "when given a query" do
      before(:each) do
        @query = "york new"
        @options = {}
      end

      it "should return an array of entities" do
        expect(@client.entity.search(@query, @options).collect { |e| e.class.name }.uniq).to eq(["LittlesisClient::Entity"])
      end

      it "should return valid entities" do
        expect(@client.entity.search(@query, @options).map(&:valid?).uniq).to eq([true])
      end
      
      it "should return matching entities" do
        expect(@client.entity.search(@query, @options).collect do |e|
          entity = @client.entity.get_with_details(e.id)
          @query.split(" ").collect do |term|
            reg = Regexp.new(term)
            names = entity.details[:Aliases] << entity.name
            names.collect { |n| (reg =~ n).nil? }
          end
        end.flatten).to include(true)
      end
      
      context "when limited to types" do
        before(:each) do
          @options[:type_ids] = 29
        end
        
        it "should only return entities with that type" do
          @type = @client.entity.type_names([29]).first
          expect(@client.entity.search(@query, @options).collect do |e|
            @client.entity.get_with_details(e.id).details[:types].include? @type
          end.uniq).to eq([true])
        end
      end
      
      context "when given a limit" do
        before(:each) do
          @num = 5
          @options[:num] = @num
        end
        
        it "should return no more than that many entities" do
          expect(@client.entity.search(@query, @options).count).to be <= @num
        end
      end
      
      context "when given a page number" do
        it "should return entities that aren't on other pages" do
          @entities1 = @client.entity.search(@id, { :page => 1, :num => 5 })
          @entities2 = @client.entity.search(@id, { :page => 2, :num => 5 })
          expect(@entities1.map(&:id) & @entities2.map(&:id)).to eq([])
        end
      end
    end
    
    context "when given a nonsense query" do
      before(:each) do
        @query = "blehblehblehblehblehblehblehbleh"
        @options = {}
      end
      
      it "should not return any entities" do
        expect(@client.entity.search(@query, @options).count).to eq(0)       
      end      
    end
  end
  
  describe "#get_by_external_id" do
    context "when given a valid external id" do
      before(:each) do
        @key = "bioguide_id"
        @value = "O000167"
      end
      
      it "should return the entity with that external id" do
        expect(@client.entity.get_by_external_id(@key, @value).first.id.to_i).to eq(13503)
      end
    end
    
    context "when given a bogus external id" do
      before(:each) do
        @key = "bioguide_id"
        @value = "9999999999999"
      end
      
      it "should an empty array" do
        expect(@client.entity.get_by_external_id(@key, @value).count).to eq(0)
      end    
    end
  end
end