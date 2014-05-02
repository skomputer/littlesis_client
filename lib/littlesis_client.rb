require 'active_model'
require 'active_support'
# require 'active_support/inflector'
require 'faraday'
require 'faraday_middleware'
require 'logger'

class LittlesisClient
  attr_reader :conn, :last_request, :last_response
  attr_accessor :host, :api_key

  def initialize(api_key, host=nil)
    @host = host
    @api_key = api_key
    @conn = Faraday.new(:url => "http://#{@host}") do |conn|
      conn.response   :json, :content_type => /\bjson$/
      conn.adapter    Faraday.default_adapter
    end
  end

  def url_prefix=(url)
    @conn.url_prefix = url
  end

  # returns response object and raises exceptions for certain http error codes
  def get(url, params={})
    raise AuthenticationError, "You must use an api key" if @api_key.nil?
    params.merge!( :_key => @api_key )

    @last_response = @response = @conn.get(url, params)
    @last_request = { :url => @response.env[:url], :headers => @response.env[:request_headers] }

    case @response.status
    when 400
      raise InvalidRequestDataError, "Invalid request data: #{@response.body.to_s}"
    when 401
      raise AuthenticationError, "Bad credentials"
    when 404
      raise InvalidRequestError, "Resource doesn't exist: #{@response.env[:url]}"
    when 405
      raise InvalidRequestError, "Unrecognized request URL: #{@response.env[:url]}"
    when 500
      raise ServerError, @response.body.to_s
    else
      @response
    end
  end

  # create accessors for models
  %w(Entity Relationship List Image).each do |model_name|
    
    # method name is snake case of model name
    method_name = model_name.underscore
    
    # define the method for each model
    class_eval <<-EOM
      def #{method_name}

        # memoize
        return @#{method_name} unless @#{method_name}.nil?

        # create a copy of the class
        @#{method_name} = Class.new(#{model_name})

        # set the copy's 'client' value to this LittlesisClient instance 
        @#{method_name}.client = self

        def @#{method_name}.model_name
          #{model_name}.model_name          
        end

        # return the new class
        @#{method_name}
      end
    EOM
  end
      
  # exception classes for various bad situations
  class Error < StandardError; end
  class InvalidRequestError < Error; end                    # errors caused by invalid requests from the user
  class InvalidRequestDataError < InvalidRequestError; end  # errors caused by invalid requests from the user
  class AuthenticationError < Error; end                    # errors caused by invalid responses from the server
  class ServerError < Error; end                            # errors caused by server-side problems
end

require 'littlesis_client/model'
require 'littlesis_client/entity'
require 'littlesis_client/relationship'
require 'littlesis_client/list'
require 'littlesis_client/image'
