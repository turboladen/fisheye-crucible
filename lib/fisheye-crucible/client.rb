require 'rubygems'
require 'fisheye-crucible'
require 'rest-client'

class FisheyeCrucible::Client

  ##
  # Sets up a Rest object to interact with the server(s).
  # 
  # @param [String] server The base URL of the server to connect to.
  def initialize(server)
    @server = server
    @fisheye_rest = RestClient::Resource.new(@server)
    @token = nil
  end
end