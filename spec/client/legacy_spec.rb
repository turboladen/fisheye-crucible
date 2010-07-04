require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'fisheye-crucible/client/legacy'

describe FisheyeCrucible::Client::Legacy do
  include FisheyeCrucible

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

  context "revision" do
    REVISION_RESPONSE =<<-EOF
<response><revision path="README.txt" rev="5774" author="parrt" date="2009-03-01T22:40:41.00Z" state="deleted" totalLines="0" linesAdded="0" linesRemoved="123" csid="5774" ancestor="5646"><log>mking tool dir</log></revision>
</response>
      EOF
    it "should return a Hash of properties" do
      @fc.revision('antlr', '', '5774').class.should == Hash
    end
  end
end