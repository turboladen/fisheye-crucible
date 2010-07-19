$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'fisheye_crucible_exception'

module FisheyeCrucible
  VERSION = '0.0.1'
  WWW = 'http://github.com/turboladen/fisheye-crucible'
end