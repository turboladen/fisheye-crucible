Before do
  @fc = FisheyeCrucible::Client::Legacy.new 'http://sandbox.fisheye.atlassian.com'
end

at_exit do
  @fc.logout if @fc
end
