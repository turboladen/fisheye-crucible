require 'rubygems'
require 'fisheye-crucible'
require 'rest-client'

# This is the parent class for accessing Fisheye/Crucible.  This will change
#   quite a bit once work on the current Fisheye/Crucible gets started.  For
#   now, look at the docs for FisheyeCrucible::Client::Legacy to get started.
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