class LittlesisClient::Entity < LittlesisClient::Model
  attr_accessor :id, :name, :description, :summary, 
    :primary_type, :parent_id,
    :start_date, :end_date, :is_current,
    :website, :uri, :api_uri,
    :updated_at,
    :details,
    :relationships
    
  validates_presence_of :id, :name, :primary_type, :uri, :api_uri

  def self.model_name
    "Entity"
  end

  def self.url(id, path=nil)
    "#{model_name.downcase}/#{id}#{path}.json"
  end
  
  def self.get_with_details(id)
    new(get_hash(id, "/details"))
  end

  def self.get_many(ids, details=false)
    url = "/batch/#{model_name.downcase.pluralize}.json"
    params = { :ids => ids.join(',') }
    params[:details] = 1 if details
    response = client.get(url, params).body["Response"]["Data"][model_name.pluralize][model_name]
    return [] if response.nil?    
    response.collect { |data| new(data) }
  end

  # valid options keys are :category_ids, :num, :page, :order
  def self.get_with_relationships(id, options={})
    response = client.get(url(id, "/relationships"), options).body["Response"]["Data"]
    entity = new(response["Entity"])
    rels = response["Relationships"]["Relationship"]
    entity.relationships = make_array(rels) do |data| 
      LittlesisClient::Relationship.new(data)
    end unless rels.nil?
    entity  
  end

  # valid options keys are :category_ids, :num, :page, :is_current, :order
  def self.get_related_entities(id, options={})
    response = client.get(url(id, "/related"), options).body["Response"]["Data"]
    entity = new(response["Entity"])
    related = response["RelatedEntities"]["Entity"]
    return [] if related.nil?
    make_array(related) { |data| new(data) }
  end

  def self.get_relationships_with_related_entities(id, options={})
    options[:sort] = "relationship"
    response = client.get(url(id, "/related"), options).body["Response"]["Data"]
    rels = response["Relationships"]["Relationship"]
    return [] if rels.nil?
    rels = make_array(rels) do |data|
      r = LittlesisClient::Relationship.new(data)
      e = new(data['RelatedEntity'])
      if e.id == r.entity1_id and e.id == r.entity2_id
        r.entity1 = r.entity2 = e
      elsif e.id == r.entity1_id
        r.entity1 = e
      else
        r.entity2 = e
      end
      r
    end
  end
  
  def self.get_related_entities_by_category(id, options={})
    options[:sort] = "category"
    categories = {}
    response = client.get(url(id, "/related"), options).body["Response"]["Data"]
    cats = response["RelationshipCategories"]["Category"]
    return categories if cats.nil?
    cats.each do |hash|
      related = hash["RelatedEntities"]["Entity"]
      categories[hash["id"].to_i] = make_array(related) { |data| new(data) } unless related.nil?
    end
    categories  
  end
  
  def self.get_leadership(id, options={})
    response = client.get(url(id, "/leadership"), options).body["Response"]["Data"]
    related = response["Leaders"]["Entity"]
    return [] if related.nil?
    make_array(related) { |data| new(data) }
  end
  
  def self.get_leadership_degree2(id, options={})
    response = client.get(url(id, "/leadership/degree2"), options).body["Response"]["Data"]
    related = response["Leaders"]["Leader"]
    return [] if related.nil?
    make_array(related) { |data| new(data) }
  end

  def self.get_orgs(id, options={})
    response = client.get(url(id, "/orgs"), options).body["Response"]["Data"]
    related = response["Orgs"]["Entity"]
    return [] if related.nil?
    make_array(related) { |data| new(data) }
  end
  
  def self.get_second_degree_entities(id, options={})
    response = client.get(url(id, "/related/degree2"), options).body["Response"]["Data"]
    related = response["Degree2Entities"]["Entity"]
    return [] if related.nil?
    make_array(related) { |data| new(data) }    
  end
  
  def self.get_lists(id)
    response = client.get(url(id, "/lists")).body["Response"]["Data"]
    lists = response["Lists"]["List"]
    return [] if lists.nil?
    make_array(lists) { |data| LittlesisClient::List.new(data) }
  end
  
  def self.get_images(id)
    response = client.get(url(id, "/images")).body["Response"]["Data"]
    images = response["Images"]["Image"]
    return [] if images.nil?
    make_array(images) { |data| LittlesisClient::Image.new(data) }  
  end
  
  def self.get_featured_image_url(id)
    images = get_images(id)
    if images.count > 0
      images.find { |i| i.is_featured = '1' }.uri
    else
      entity = get(id)
      filename = entity.primary_type == "Person" ? "anon.png" : "anons.png"
      LittlesisClient::Image::DEFAULT_IMAGE_PATH + filename
    end
  end

  def self.get_political(id)
    client.get(url(id, "/political")).body
  end

  def self.get_articles(id)
    client.get(url(id, "/articles")).body
  end

  def self.search(query, options={})
    options[:q] = query
    response = client.get("/entities.json", options).body["Response"]["Data"]
    entities = response["Entities"]["Entity"]
    return [] if entities.nil?
    make_array(entities) { |data| new(data) }
  end
  
  def self.get_by_external_id(key, value)
    response = client.get("/entities/#{key}/#{value}.json").body["Response"]["Data"]
    entities = response["Entities"]["Entity"]
    return [] if entities.nil?
    make_array(entities) { |data| new(data) }
  end

  def self.types
    response = client.get("/entities/types.json")
    response.body["Response"]["Data"]["EntityTypes"]["EntityType"]  
  end
  
  def self.type_names(ids=[])
    types.keep_if { |t| ids.to_a.empty? or ids.include? t["id"].to_i }.collect { |t| t["name"] }
  end
      
  def initialize(data)
    @details = {}
    @relationships = []
    super(data)
  end
  
  def set_data(data)
    data.each do |k, v|
      method = (k.to_s + "=").to_sym
      if respond_to? method
        send(method, self.class.symbolize_keys(v))
      elsif k == "types"
        details[k.to_sym] = v.split(",")
      elsif k == "Aliases"
        details[k.to_sym] = self.class.make_array(v["Alias"])
      elsif k == "Relationships"
        @relationships = self.class.make_array(v["Relationship"]) { |r| LittlesisClient::Relationship.new(r) }
      else
        details[k.to_sym] = self.class.symbolize_keys(v)
      end
    end
  end  
end
