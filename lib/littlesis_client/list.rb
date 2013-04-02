class LittlesisClient::List < LittlesisClient::Model
  attr_accessor :id, :name, :description, :is_ranked,
    :updated_at, :uri, :api_uri,
    :entities

  validates_presence_of :id, :name, :description, :is_ranked
  
  def self.model_name
    "List"
  end

  def self.url(id, path=nil)
    "#{model_name.downcase}/#{id}#{path}.json"
  end
  
  def self.get_with_entities(id, options={})
    response = client.get(url(id, "/entities"), options).body["Response"]["Data"]
    list = new(response["List"])
    entities = response["Entities"]["Entity"]
    list.entities = make_array(entities) do |data| 
      LittlesisClient::Entity.new(data)
    end unless entities.nil?
    list    
  end
end