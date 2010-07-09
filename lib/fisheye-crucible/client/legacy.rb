require 'rubygems'
require 'fisheye-crucible/client'
require 'fisheye-crucible/type_converter'
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
    token_xml = @fisheye_rest['api/rest/login'].post :username => username, 
      :password => password

    response = token_xml.to_ruby
    if response.class == FisheyeCrucibleError
      raise response
    elsif response.class == String
      @token = response
      return @token
    end
    return nil
  end

  ##
  # Logs out of Fisheye/Crucible.
  #
  # @return [Boolean] Returns true if logout was successful.
  def logout
    result_xml = @fisheye_rest['api/rest/logout'].post :auth => @token
    debug(result_xml)

    response = result_xml.to_ruby

    if response.class == FisheyeCrucibleError
      raise response
    else
      @token = '' if response == true
      return response
    end
  end

  ##
  # Gets the version of Fisheye.
  # 
  # @return [String] The version of Fisheye.
  # @alias fisheyeVersion
  def fisheye_version
    version_xml = @fisheye_rest['api/rest/fisheyeVersion'].get
    response = version_xml.to_ruby

    if response.class == FisheyeCrucibleError
      raise response
    else
      return response
    end
  end
  alias_method :fisheyeVersion, :fisheye_version

  ##
  # Gets the version of Crucible.
  # 
  # @return [String] The version of Crucible.
  def crucible_version
    version_xml = @fisheye_rest['api/rest/crucibleVersion'].get

    response = version_xml.to_ruby

    if response.class == FisheyeCrucibleError
      raise response
    else
      return response
    end
  end
  alias_method :crucibleVersion, :crucible_version

  ##
  # Gets the list of repositories to an array.
  # 
  # @return [Array] The list of repositories.
  def repositories
    repositories = []

    repos_xml = @fisheye_rest['api/rest/repositories'].post :auth => @token
    response = repos_xml.to_ruby

    if response.class == FisheyeCrucibleError
      raise response
    else
      return response
    end
  end
  alias_method :listRepositories, :repositories

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

    response = paths_xml.to_ruby

    if response.class == FisheyeCrucibleError
      raise response
    else
      return response
    end
  end
  alias_method :listPaths, :list_paths_from

  ##
  # Gets details about a specific file/directory revision from the given
  #   repository.
  # 
  # @param [String] repository The repository in which the file resides.
  # @param [String] path The path, relative to the repository, in which the file
  #   resides.
  # @param [Fixnum] revision The revision of the file/directory to get the info
  #   about.
  # @return [Hash] The list of details about the file revision.
  def revision(repository, path, revision)
    revision_xml = @fisheye_rest['api/rest/revision'].post :auth => @token,
      :rep => repository,
      :path => path,
      :rev => revision.to_s

    response = revision_xml.to_ruby

    if response.class == FisheyeCrucibleError
      raise response
    else
      return response
    end
  end
  alias_method :getRevision, :revision

  ##
  # Gets tags associated with a file/directory revision.
  # 
  # @param [String] repository The repository in which the file resides.
  # @param [String] path The path, relative to the repository, in which the file
  #   resides.
  # @param [Fixnum] revision The revision of the file/directory to get the tags
  #   for.
  # @return [Hash] The list of tags for the file revision.
  def tags(repository, path, revision)
    tags_xml = @fisheye_rest['api/rest/tags'].post :auth => @token,
      :rep => repository,
      :path => path,
      :rev => revision.to_s

    #debug tags_xml
    return tags_xml.to_ruby
=begin
      doc = REXML::Document.new(tags_xml)
    
      if doc.root.name.eql? 'error'
        raise doc.root.text
      elsif doc.root.name.eql? 'response' and doc.root.has_elements?
        # TODO: Not sure if this works since I can't find any files
        #   with tags.
        return doc.root.elements['//tags'].text
      elsif doc.root.name.eql? 'response' and !doc.root.has_elements?
        return ""
      end
=end
  end
  alias_method :listTagsForRevision, :tags

  ##
  # Gets the history for a file/directory, which is a list of revisions and
  #   their associated info.
  # 
  # @param [String] repository The repository for which to get the history
  #   info about.
  # @param [String] path The path, relative to root, for which to get info
  #   about.
  # @return [Array<Hash>] The list of revisions.
  def path_history(repository, path)
    history_xml = @fisheye_rest['api/rest/pathHistory'].post :auth => @token,
      :rep => repository,
      :path => path

    response = history_xml.to_ruby

    if response.class == FisheyeCrucibleError
      raise response
    else
      return response
    end
  end
  alias :pathHistory :path_history

  ##
  # Gets information about a changeset.
  # 
  # @param [String] repository The repository for which to get the changeset
  #   info about.
  # @param [Fixnum] csid The changeset ID to get the info about.
  # @return [Hash] All of the changeset info as defined by the API.
  def changeset(repository, csid)
    changeset_xml = @fisheye_rest['api/rest/changeset'].post :auth => @token,
      :rep => repository,
      :csid => csid.to_s

    response = changeset_xml.to_ruby

    if response.class == FisheyeCrucibleError
      raise response
    else
      return response
    end
  end
  alias_method :getChangeset, :changeset
rescue FisheyeCrucibleError => e
  puts e.message
end