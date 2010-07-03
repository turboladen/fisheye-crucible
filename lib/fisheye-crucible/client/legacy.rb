require 'rubygems'
require 'fisheye-crucible/client'
require 'rexml/document'

##
# This class provides access to the Fisheye/Crucible REST API that was
#   used before version 2.0.  More info here:
#   http://confluence.atlassian.com/display/FECRUDEV/FishEye+Legacy+Remote+API
#
# All methods are named in Ruby style, however aliases are provided that are
#   named after the Fisheye/Crucible function name (if different).
class FisheyeCrucible::Client::Legacy < FisheyeCrucible::Client

  def initialize(server)
    super(server)
  end

  ##
  # Logs in with provided credentials and returns a token that can be used for
  #   all other calls.
  # 
  # @param [String] username The user to login with.
  # @param [String] password The password of the user to login with.
  # @return [String] The token to use for other calls.
  def login(username=nil, password=nil)
    begin
      token_xml = @fisheye_rest['api/rest/login'].post :username => username, 
        :password => password

puts token_xml
      doc = REXML::Document.new(token_xml)
      if doc.elements['error']
        raise SecurityError, "Login failed.  #{doc.elements['error'].text}"
      elsif doc.elements['response']
        @token = doc.root.elements['//string'].text
      end
      return @token
    rescue => e
      puts e.inspect
    end
    return nil
  end

  ##
  # Removes unneeded XML tags that come along with Rest responses.
  # 
  # @param [String] string The string to remove the XML from.
  # @return [String] The string without the XML tags.
  def strip_response_xml_from string
    doc = REXML::Document.new(string)
    new_string = doc.root.elements['//string'].text
  end

  ##
  # Logs out of Fisheye/Crucible.
  #
  # @return [Boolean] Returns true if logout was successful.
  def logout
    begin
      result_xml = @fisheye_rest['api/rest/logout'].post :auth => @token

      not_valid = "Given auth token not valid"
      if result_xml.include? not_valid
        raise SecurityError, not_valid
      end
    rescue SecurityError => e
      puts e
      return false
    rescue RuntimeError => e
      puts e.inspect
      return nil
    end

    doc = REXML::Document.new(result_xml)
    result_string = doc.root.elements['//boolean'].text

    if result_string.eql? 'true'
      return true
    elsif result_string.eql? 'false'
      # Not sure if we could ever get here, but just in case
      return false
    else
      return nil
    end
  end

  ##
  # Gets the version of Fisheye.
  # 
  # @return [String] The version of Fisheye.
  def fisheye_version
    version_xml = @fisheye_rest['api/rest/fisheyeVersion'].get
    
    doc = REXML::Document.new(version_xml)
    version = doc.root.elements['//string'].text
  end
  alias :fisheyeVersion :fisheye_version

  ##
  # Gets the version of Crucible.
  # 
  # @return [String] The version of Crucible
  def crucible_version
    version_xml = @fisheye_rest['api/rest/crucibleVersion'].get

    doc = REXML::Document.new(version_xml)
    version = doc.root.elements['//string'].text
  end
  alias :crucibleVersion :crucible_version

  ##
  # Gets the list of repositories to an array.
  # 
  # @return [Array] The list of repositories.
  def repositories
    repositories = []

    repos_xml = @fisheye_rest['api/rest/repositories'].get
    #repos_xml = @fisheye_rest['api/rest/repositories'].post :auth => @token

    doc = REXML::Document.new(repos_xml)
    doc.root.each_element do |element|
      repositories << element.text
    end
    return repositories
  end
  alias :listRepositories :repositories

  ##
  # Gets the file/dir listing from a repository.
  # 
  # @param [String] repository The repository to get the listing for.
  # @param [String] path The directory in the repository to get the listing for.
  #   If no path is given, listing is from /.
  # @return [Hash<String><Hash>] The listing, where the key is the file/directory
  #   and the value is another Hash that contains properties of the file/directory.
  def list_paths_from(repository, path='')
    paths_xml = @fisheye_rest['api/rest/listPaths'].post :auth => @token,
      :rep => repository,
      :path => path

    path_names = {}
    doc = REXML::Document.new(paths_xml)
    doc.root.elements.each("pathinfo") do |element|
      path_name = element.attributes["name"]
      path_names[path_name] = { :is_file => element.attributes["isFile"],
        :is_dir => element.attributes["isDir"],
        :is_head_deleted => element.attributes["isHeadDeleted"]
      }
    end
    path_names
  end
  alias :listPaths :list_paths_from
end