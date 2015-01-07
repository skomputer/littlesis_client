class LittlesisClient::Relationship < LittlesisClient::Model
  attr_accessor :id, :entity1_id, :entity2_id, :category_id,
    :description1, :description2, :amount, :goods, :notes,
    :start_date, :end_date, :is_current,
    :uri, :api_uri,
    :updated_at,
    :details,
    :entity1, :entity2

  validates_presence_of :id, :entity1_id, :entity2_id, :category_id

  def self.model_name
    "Relationship"
  end

  def self.url(id, path=nil)
    "#{model_name.downcase}/#{id}#{path}.json"
  end

  def self.categories
    response = client.get("/relationships/categories.json")
    response.body["Response"]["Data"]["RelationshipCategories"]["RelationshipCategory"]
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
    make_array(response).collect { |data| new(data) }
  end

  def self.between_entities(entity1_id, entity2_id, cat_ids=[])
    url = "/relationships/#{entity1_id};#{entity2_id}.json"
    params = {}
    params[:cat_ids] = cat_ids.to_a.join(",") unless cat_ids.to_a.empty?
    response = client.get(url, params).body["Response"]["Data"][model_name.pluralize][model_name]
    return [] if response.nil?
    make_array(response).collect { |data| new(data) }
  end

  def initialize(data)
    @details = {}
    super(data)
  end
  
  def set_data(data)
    data.each do |k, v|
      v = nil if v == ""
      method = (k.to_s + "=").to_sym
      if respond_to? method
        send(method, self.class.symbolize_keys(v))
      elsif k == "Entity1"
        @entity1 = LittlesisClient::Entity.new(v)
      elsif k == "Entity2"
        @entity2 = LittlesisClient::Entity.new(v)
      else
        details[k.to_sym] = self.class.symbolize_keys(v)
      end
    end
  end
end