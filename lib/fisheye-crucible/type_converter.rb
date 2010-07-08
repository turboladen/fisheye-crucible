require 'rexml/document'
require 'fisheye-crucible'

#class FisheyeCrucible::TypeConverter < String
class String
  def to_ruby
    doc = REXML::Document.new self

    type = doc.root.name
    puts type
    message = doc.root.text
    puts message

    responses = []
    response_type = ''

    if type == 'error'
      return FisheyeCrucibleError.new(message)
    elsif type == 'response'
      doc.root.each_element do |element|
        # The data type
        response_type = element.name
        puts "response type: #{response_type}"

        # Text for the next element
        responses << element.text
        puts "response text: #{element.text}"
      end
    else
    end

    puts "responses length = #{responses.length}"
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
    end
  end

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
  # @return [Boolean] true, false, nil.
  def string_to_true_false(string)
    return true if string.eql? 'true'
    return false if string.eql? 'false'
    return nil
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
end