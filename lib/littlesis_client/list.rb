class LittlesisClient::List < LittlesisClient::Model
  attr_accessor :id, :name, :description, :is_ranked,
    :updated_at, :uri, :api_uri,
    :entities

  validates_presence_of :id, :name, :is_ranked
  
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

  def self.get_entity_ids(id, options={})
    client.get(url(id, "/entity-ids"), options).body
  end

  def self.get_network_links(id, options={})
    client.get(url(id, "/network-links"), options).body
  end

  def self.get_images(id, options={})
    client.get(url(id, "/images"), options).body
  end
end