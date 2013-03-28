class LittlesisClient::Entity < LittlesisClient::Model
  attr_accessor :id, :name, :description, :summary, 
    :primary_type, :parent_id,
    :start_date, :end_date, :is_current,
    :website, :uri, :api_uri,
    :updated_at,
    :details

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
    url = "/batch/#{model_name.downcase.pluralize}.json?ids=#{ids.join(',')}"
    url << "&details=1" if details
    response = client.get(url).body["Response"]["Data"][model_name.pluralize][model_name]
    return [] if response.nil?    
    response.collect do |hash|
      new(hash)
    end
  end
  
  def details
    @details ||= {}
  end

  def set_data(data)
    data.each do |k, v|
      method = (k.to_s + "=").to_sym
      if respond_to? method
        send(method, self.class.symbolize_keys(v))
      elsif k == "types"
        details[k.to_sym] = v.split(",")
      elsif k == "Aliases"
        details[k.to_sym] = v["Alias"]
      else
        details[k.to_sym] = self.class.symbolize_keys(v)
      end
    end
  end  
end