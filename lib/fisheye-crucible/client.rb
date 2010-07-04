require 'rubygems'
require 'fisheye-crucible'
require 'rest-client'

class FisheyeCrucible::Client

  # @return [Boolean] Turn debug on or off
  attr_accessor :do_debug

  ##
  # Sets up a Rest object to interact with the server(s).
  # 
  # @param [String] server The base URL of the server to connect to.
  def initialize(server)
    @server = server
    @fisheye_rest = RestClient::Resource.new(@server)
    @token = nil
    @do_debug = false
  end

  ##
  # Print out string if debug is turned on.
  # 
  # @param [String] string The debug string to print out.
  def debug(string)
    if @do_debug
      puts string
    end
  end
end