require 'rubygems'
require 'fisheye-crucible/client'
require 'fisheye-crucible/type_converter'
require 'rexml/document'

# This class provides access to the Fisheye/Crucible REST API that was
# used before version 2.0.  More info here:
# http://confluence.atlassian.com/display/FECRUDEV/FishEye+Legacy+Remote+API
#
# All methods are named in Ruby style, however aliases are provided that are
# named after the Fisheye/Crucible function name (if different).
class FisheyeCrucible::Client::Legacy < FisheyeCrucible::Client
  def initialize(server)
    super(server)
  end

  # Logs in with provided credentials and returns a token that can be used for
  # all other calls.
  #
  # @param [String] username The user to login with.
  # @param [String] password The password of the user to login with.
  # @return [String] The token to use for other calls.
  def login(username=nil, password=nil)
    @token = build_rest_call('api/rest/login',
      :post,
      {
        :username => username,
        :password => password
      }
    )
  end

  # Logs out of Fisheye/Crucible.
  #
  # @return [Boolean] Returns true if logout was successful.
  def logout
    unless @token
      error_message = "Can't log out--it seems you're not logged in."
      raise FisheyeCrucible::Error, error_message
    end

    result = build_rest_call('api/rest/logout', :post, { :auth => @token })

    @token = '' if result == true

    result
  end

  # Gets the version of Fisheye.
  #
  # @return [String] The version of Fisheye.
  def fisheye_version
    build_rest_call('api/rest/fisheyeVersion', :get)
  end
  alias_method :fisheyeVersion, :fisheye_version

  # Gets the version of Crucible.
  #
  # @return [String] The version of Crucible.
  def crucible_version
    build_rest_call('api/rest/fisheyeVersion', :get)
  end
  alias_method :crucibleVersion, :crucible_version

  # Gets the list of repositories to an array.
  #
  # @return [Array] The list of repositories.
  def repositories
    build_rest_call('api/rest/repositories',
      :post,
      { :auth => @token }
    )
  end
  alias_method :listRepositories, :repositories

  # Gets the file/dir listing from a repository.
  #
  # @param [String] repository The repository to get the listing for.
  # @param [String] path The directory in the repository to get the listing
  #   for.  If no path is given, listing is from /.
  # @return [Hash<String><Hash>] The listing, where the key is the
  #   file/directory and the value is another Hash that contains properties of
  #   the file/directory.
  def list_paths_from(repository, path='')
    build_rest_call('api/rest/listPaths',
      :post,
      {
        :auth => @token,
        :rep => repository,
        :path => path
      }
    )
  end
  alias_method :listPaths, :list_paths_from

  # Gets details about a specific file/directory revision from the given
  # repository.
  #
  # @param [String] repository The repository in which the file resides.
  # @param [String] path The path, relative to the repository, in which the
  #   file resides.
  # @param [Fixnum] revision The revision of the file/directory to get the info
  #   about.
  # @return [Hash] The list of details about the file revision.
  def revision(repository, path, revision)
    build_rest_call('api/rest/revision',
      :post,
      {
        :auth => @token,
        :rep => repository,
        :path => path,
        :rev => revision.to_s
      }
    )
  end
  alias_method :getRevision, :revision

  # Gets tags associated with a file/directory revision.
  #
  # @param [String] repository The repository in which the file resides.
  # @param [String] path The path, relative to the repository, in which the
  #   file resides.
  # @param [Fixnum] revision The revision of the file/directory to get the tags
  #   for.
  # @return [Hash] The list of tags for the file revision.
  def tags(repository, path, revision)
    puts "WARNING: This method is untested!"

    tags = build_rest_call('api/rest/tags',
      :post,
      {
        :auth => @token,
        :rep => repository,
        :path => path,
        :rev => revision.to_s
      }
    )
=begin
    tags_xml = @fisheye_rest['api/rest/tags'].post :auth => @token,
      :rep => repository,
      :path => path,
      :rev => revision.to_s

    #debug tags_xml
    return tags_xml.to_ruby
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

  # Gets the history for a file/directory, which is a list of revisions and
  # their associated info.
  #
  # @param [String] repository The repository for which to get the history
  #   info about.
  # @param [String] path The path, relative to root, for which to get info
  #   about.
  # @return [Array<Hash>] The list of revisions.
  def path_history(repository, path='')
    build_rest_call('api/rest/pathHistory',
      :post,
      {
        :auth => @token,
        :rep => repository,
        :path => path
      }
    )
  end
  alias :pathHistory :path_history

  # Gets information about a changeset.
  #
  # @param [String] repository The repository for which to get the changeset
  #   info about.
  # @param [Fixnum] csid The changeset ID to get the info about.
  # @return [Hash] All of the changeset info as defined by the API.
  def changeset(repository, csid)
    build_rest_call('api/rest/changeset',
      :post,
      {
        :auth => @token,
        :rep => repository,
        :csid => csid.to_s
      }
    )
  end
  alias_method :getChangeset, :changeset

  # Gets all changeset IDs (csids) that match the parameters given.
  #
  # @param [String] repository The repository for which to get the changesets
  #   for.
  # @param [String] path Path to the item(s) to get changesets for.  Can only
  #   be a directory.
  # @param [Fixnum] max_return The maximum number of values to return.  If not
  #   set, this is limited by the internal Fisheye server.  If set, the most
  #   recent results are returned.
  # @param [DateTime] start_date The DateTime object representing the start
  #   date for which to filter the query.
  # @param [DateTime] end_date The DateTime object representing the end date
  #   for which to filter the query.
  # @return [Hash<Array,String>] :csids => the Array of changeset IDs;
  #   :max_return => Max values returned.
  def changesets(repository, path='/', max_return=nil, start_date=nil,
        end_date=nil)
    build_rest_call('api/rest/changesets',
      :post,
      {
        :auth => @token,
        :rep => repository,
        :path => path,
        :start => start_date,
        :end => end_date,
        :maxReturn => max_return
      }
    )
  end
  alias_method :listChangesets, :changesets

  # Sends an EyeQL query to the server for a given repository.  Return types
  # can differ depending on the 'return-clause' used in the query.  For more
  # info, see http://confluence.atlassian.com/display/FISHEYE/EyeQL+Reference+Guide.
  #
  # @param [String] repository The repository to run the EyeQL query on.
  # @param [String] query The EyeQL query to run.
  # @return [Object]
  def query(repository, query)
    build_rest_call('api/rest/query',
      :post,
      {
        :auth => @token,
        :rep => repository,
        :query => query
      }
    )
  end

  ##
  # Privates
  private

  # Builds and makes the REST call from the arguments given.
  #
  # @param [String] url The API portion of the URL as defined by the API.
  # @param [String] action 'post' or 'get'.
  # @param [Hash] options The REST params to pass to the REST call.
  # @return [Object] The Object that #to_ruby returns.
  def build_rest_call(url, action, options=nil)
    rest_call = "@fisheye_rest['#{url}'].#{action}"

    unless options.nil?
      actual_options = non_nil_options_in options

      option_count = 1
      actual_options.each_pair do |key,value|
        unless value.nil?
          rest_call << " :#{key} => '#{value}'"
          rest_call << ',' unless option_count == actual_options.length
          option_count += 1
        end
      end
    end

    response_xml = eval(rest_call)
    response = response_xml.to_ruby

    if response.class == FisheyeCrucible::Error
      raise response
    end

    response
  end

  # Removes all key/value pairs from Hash that have a nil value and returns
  # a Hash with keys that have values.
  #
  # @param [Hash] options The Hash to remove nil key/value pairs from.
  def non_nil_options_in options
    non_nil_options = {}
    options.each_pair do |k,v|
      non_nil_options[k] = v unless v.nil?
    end

    non_nil_options
  end
rescue FisheyeCrucible::Error => e
  puts e.message
end
