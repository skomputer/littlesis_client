class LittlesisClient::Entity < LittlesisClient::Model
  attr_accessor :id, :name, :description, :summary, 
    :primary_type, :parent_id,
    :start_date, :end_date, :is_current,
    :website, :uri, :api_uri,
    :updated_at,
    :details,
    :relationships,
    :related_entities

  validates_presence_of :id, :name, :primary_type, :uri, :api_uri

  def self.model_name
    "Entity"
  end

  def self.url(id, path=nil)
    "#{model_name.downcase}/#{id}#{path}.json"
  end
  
  def self.details(id)
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
    entity.relationships = rels.collect { |data| LittlesisClient::Relationship.new(data) } unless rels.nil?
    entity  
  end
  
  # valid options keys are :category_ids, :num, :page, :is_current
  def self.get_with_related_entities(id, options={})
    response = client.get(url(id, "/related"), options).body["Response"]["Data"]
    entity = new(response["Entity"])
    related = response["RelatedEntities"]["Entity"]
    entity.related_entities = related.collect { |data| new(data) } unless related.nil?
    entity
  end
  
  def initialize(data)
    @details = {}
    @relationships = []
    @related_entities = []
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
        details[k.to_sym] = make_array(v["Alias"])
      elsif k == "Relationships"
        @relationships = make_array(v["Relationship"]) { |r| LittlesisClient::Relationship.new(r) }
      else
        details[k.to_sym] = self.class.symbolize_keys(v)
      end
    end
  end  
end