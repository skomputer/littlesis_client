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

  def initialize(data)
    @details = {}
    super(data)
  end
  
  def set_data(data)
    data.each do |k, v|
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
  
  def self.get_with_details(id)
    new(get_hash(id, "/details"))
  end  
end