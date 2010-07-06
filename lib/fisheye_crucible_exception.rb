class FisheyeCrucibleError < Exception
  def message
    puts "#{self.class}: #{self.to_s}"
  end
end