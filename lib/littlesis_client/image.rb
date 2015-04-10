class LittlesisClient::Image < LittlesisClient::Model
  include ActiveModel::Validations        

  attr_accessor :id, :title, :caption, :is_featured, :uri, :source, :address_id

  validates_presence_of :id, :title, :is_featured, :uri, :source    

  DEFAULT_IMAGE_PATH = "http://s3.amazonaws.com/pai-littlesis/images/system/"
  
  class << LittlesisClient::Image
    undef_method :get
    undef_method :get_hash
  end
end