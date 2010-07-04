require File.dirname(__FILE__) + '../spec_helper.rb'
require 'fisheye-crucible/client/legacy'

describe FisheyeCrucible::Client::Legacy do
  include FisheyeCrucible::Client

  GOOD_USERNAME = 'gemtest'
  GOOD_PASSWORD = 'gemtest'

  before :each do
    server = 'http://sandbox.fisheye.atlassian.com'

    @fc = Client::Legacy.new(server)
  end

  after :all do
    @fc.logout
  end

  context "login" do
    it "should login successfully with good credentials" do
      token = @fc.login(GOOD_USERNAME, GOOD_PASSWORD)
      token.should match(/^\w+:\d{3}:\w{32}$/)
    end
  end
end