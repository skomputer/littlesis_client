class LittlesisClient::Image < LittlesisClient::Model
  include ActiveModel::Validations        

  attr_accessor :id, :title, :caption, :is_featured, :uri, :source

  validates_presence_of :id, :title, :is_featured, :uri, :source    
  
  class << LittlesisClient::Image
    undef_method :get
    undef_method :get_hash
  end
end