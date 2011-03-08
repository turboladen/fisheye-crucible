require 'rexml/document'
require 'fisheye-crucible'

# By adding this method to String, the #to_ruby method can be called directly
# on the return data from RestClient.  This, effectively, accomplishes turning
# a String of XML into the Ruby data types that make sense for the return types
# that Atlassian defined.
class String

  # Takes a String of XML then converts in to a correlating Ruby data type.
  # Aside from the documentation for each private method below, here is the
  # conversion table:
  #   | Fisheye/Crucible Type  | Ruby Type               |
  #   | string                 | String                  |
  #   | boolean                | TrueClass, FalseClass   |
  #   | pathinfo               | Hash with child Hashes  |
  #   | revision               | Hash                    |
  #   | history                | Array of revisions      |
  #   | changeset              | Hash                    |
  #   | changesets             | Hash of changesets      |
  #   | revisionkey            | Array with child Hashes |
  #   | row                    | Array                   |
  def to_ruby
    doc = REXML::Document.new self

    type = doc.root.name
    doc_text = doc.root.text

    responses = []
    response_type = ''

    if type == 'error'
      return FisheyeCrucibleError.new(doc_text)
    elsif type == 'response'
      doc.root.each_element do |element|
        # The data type
        response_type = element.name

        # Text for the next element
        responses << element.text
      end
    else
      message = "Not sure what to do with this response:\n#{doc_text}"
      return FisheyeCrucibleError.new(message)
    end

    # If we have 0 or 1 actual strings, return the string or ""
    if response_type.eql? 'string' and responses.length <= 1
      return string_to_string(doc)
    # If we have mulitple strings, return the Array of Strings
    elsif response_type.eql? 'string'
      return string_to_array(doc)
    elsif response_type.eql? 'boolean'
      return boolean_to_true_false(doc)
    elsif response_type.eql? 'pathinfo'
      return pathinfo_to_hash(doc)
    elsif response_type.eql? 'revision'
      return revision_to_hash(doc)
    elsif response_type.eql? 'history'
      return history_to_array(doc)
    elsif response_type.eql? 'changeset'
      return changeset_to_hash(doc)
    elsif response_type.eql? 'changesets'
      return changesets_to_hash(doc)
    elsif response_type.eql? 'revisionkey'
      return revisionkeys_to_array(doc)
    elsif response_type.eql? 'row'
      return custom_to_array(doc)
    elsif response_type.eql? ''
      return ''
    end

    message = "Response type unknown: '#{response_type}'"

    FisheyeCrucibleError.new(message)
  end

  ##
  # PRIVATES!
  private

  ##
  # Converts a REXML::Document with 1 element of type <string> into a String.
  #
  # @param [REXML::Document] xml_doc The XML document to convert.
  # @return [String] The string from the XML document.
  def string_to_string(xml_doc)
    xml_doc.root.elements[1].text
  end

  ##
  # Converts a String to its related Boolean type.  If the string doesn't
  #   contain such a type, nil is returned.
  #
  # @param [String] string The String to convert.
  # @return [Boolean,String] true, false, or the original string.
  def string_to_true_false(string)
    return true if string.eql? 'true'
    return false if string.eql? 'false'

    string
  end

  ##
  # Converts a REXML::Document with element <boolean> into a true or false
  #   value.
  #
  # @param [REXML::Document] xml_doc The XML document to convert.
  # @return [Boolean] true, false, or nil.
  def boolean_to_true_false(xml_doc)
    string_to_true_false(xml_doc.root.elements[1].text)
  end

  ##
  # Converts a REXML::Document with multiple elements of type <string> into an
  #   Array.
  #
  # @param [REXML::Document] xml_doc The XML document to convert.
  # @return [Array] The list of strings.
  def string_to_array(xml_doc)
    responses = []
    xml_doc.root.each_element do |element|
      response_type = element.name
      responses << element.text
    end

    responses
  end

  ##
  # Takes Fisheye/Crucible's <pathinfo> return type and turns it in to
  #   a Hash of Hashes.
  #
  # @param [REXML::Document] xml_doc The XML document to convert.
  # @return [Hash<Hash>] The path info as a Hash.  The Hash contains keys
  #   which are the file/directory names in the path; values for those keys
  #   are Hashes which contain the properties of that file/directory.
  def pathinfo_to_hash(xml_doc)
    path_name = ''
    path_names = {}

    xml_doc.root.each_element do |element|
      path_name = element.attributes["name"]
      path_names[path_name] = {}

      element.attributes.each_attribute do |attribute|
        next attribute if attribute.name.eql? 'name'
        boolean_value = string_to_true_false(attribute.value)
        path_names[path_name][attribute.name.to_sym] = boolean_value
      end
    end

    path_names
  end

  ##
  # Takes Fisheye/Crucible's <revision> return type and turns it in to a single
  #   Hash.
  #
  # @param [REXML::Document] xml_doc The XML document to convert.
  # @return [Hash] The info about the revision.
  def revision_to_hash(xml_doc)
    details = {}

    xml_doc.root.elements['//revision'].attributes.each do |attribute|
      # Convert the value to an Int if the string is just a number
      if attribute[1] =~ /^\d+$/
        details[attribute.first.to_sym] = attribute[1].to_i
      else
        details[attribute.first.to_sym] = attribute[1]
      end
    end
    details[:log] = xml_doc.root.elements['//log'].text

    details
  end

  ##
  # Takes Fisheye/Crucible's <history> return type and turns it in to an
  #   Array of revisions, which are Hashes.
  #
  # @param [REXML::Document] xml_doc The XML document to convert.
  # @return [Array<Hash>] The Array of revision Hashes.
  def history_to_array(xml_doc)
    revisions = []

    revisions_xml = REXML::XPath.match(xml_doc, "//revisions/revision")
    revisions_xml.each do |revision_xml|
      revision = REXML::Document.new(revision_xml.to_s)
      revisions << revision_to_hash(revision)
    end

    revisions
  end

  ##
  # Takes Fisheye/Crucible's <changeset> return type and turns it in to a Hash.
  #
  # @param [REXML::Document] xml_doc The XML document to convert.
  # @return [Hash] Hash containting the changeset history information as
  #   defined by the API.
  def changeset_to_hash(xml_doc)
    details = {}

    xml_doc.root.elements['//changeset'].attributes.each do |attribute|
      # Convert the value to an Int if the string is just a number
      int_attribute = attribute[1]
      if int_attribute =~ /^\d+$/
        details[attribute.first.to_sym] = int_attribute.to_i
      else
        details[attribute.first.to_sym] = int_attribute
      end
    end
    details[:log] = xml_doc.root.elements['//log'].text

    # Revisions is an Array of Hashes, where each Hash is a key/value pair that
    #   contains the path and revsion of one of the files/directories that's
    #   part of the changeset.
    details[:revisions] = []
    details[:revisions] << revisionkeys_to_array(xml_doc)

    details
  end

  ##
  # Takes Fisheye/Crucible's <revisionkey> return type and turns it in to an
  #   Array of Hashes.
  #
  # @param [REXML::Document] xml_doc The XML document to convert.
  # @return [Array<Hash>] The Array of path & rev data.
  def revisionkeys_to_array(xml_doc)
    revisionkeys = []

    xml_doc.root.elements.each('//revisionkey') do |element|
      revisionkey = { :path => element.attributes['path'],
        :rev => element.attributes['rev'].to_i
      }

      revisionkeys << revisionkey
    end

    revisionkeys
  end

  ##
  # Takes Fisheye/Crucible's <changesets> return type and turns it in to a
  #   Hash.
  #
  # @param [REXML::Document] xml_doc The XML document to convert.
  # @return [Hash] Contains the changeset IDs as defined by the query.
  def changesets_to_hash(xml_doc)
    changesets = {}
    changesets[:csids] = []

    changesets[:max_return] = xml_doc.root.elements['//changesets'].
      attributes['maxReturn']

    xml_doc.root.elements['//csids'].each_element do |element|
      changesets[:csids] << element.text.to_i
    end

    changesets
  end

  ##
  # Takes Fisheye/Crucible's custom <row> return type (from a query) and turns
  #   it in to an Array of Hashes containing the results from the query.
  #
  # @param [REXML::Document] xml_doc The XML document to convert.
  # @return [Array] The result from the query.
  def custom_to_array(xml_doc)
    responses = []

    xml_doc.elements.each('//row') do |element|
      response = {}
      element.each do |subs|
        if subs.is_a? REXML::Text
        else
          # TODO: If subs.text is a Boolean string, it doesn't get converted
          # to the actual Boolean.  Same if it's an int or empty string.
          response[subs.name.to_sym] = subs.text
        end
      end
      responses << response
    end

    responses
  end
end