class LittlesisClient::Model
  include ActiveModel::Validations        

  def self.client=(client)
    @client = client
  end

  def self.client
    raise "No client" unless @client
    @client 
  end

  def client
    self.class.client
  end

  def class
    return super unless super == Class
    superclass
  end

  def self.name
    return super unless super.nil?
    superclass.name
  end

  def initialize(data)
    @errors = ActiveModel::Errors.new(self)
    self.set_data(data)
  end

  def set_data(data)
    data.each do |k, v|
      method = (k.to_s + "=").to_sym
      if respond_to? method
        send(method, self.class.symbolize_keys(v))
      else
        instance_variable_set("@#{k}".to_sym, self.class.symbolize_keys(v))
      end
    end
  end

  def self.get(id, path=nil)
    new(get_hash(id, path))
  end

  def self.get_hash(id, path=nil, params={})
    response = client.get(url(id, path), params)
    response.body["Response"]["Data"][model_name]
  end

  def url
    self.class.url(id)  
  end
  
  private
  
  def self.symbolize_keys(obj)
    if obj.instance_of? Hash
      obj.keys.each do |key|
        obj[(key.to_sym rescue key) || key] = symbolize_keys(obj.delete(key))
      end
      obj
    elsif obj.instance_of? Array
      obj.collect { |e| symbolize_keys(e) }
    else
      obj
    end
  end

  def make_array(array)
    array = [ array ] unless array.is_a? Array
    array.collect! { |i| yield i } if block_given?
    array
  end
end