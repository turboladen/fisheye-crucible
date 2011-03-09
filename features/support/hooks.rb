Before do
  @fc = FisheyeCrucible::Client::Legacy.new 'http://sandbox.fisheye.atlassian.com'
end

=begin
at_exit do
  @fc.logout if @fc
end
=end
