require File.dirname(__FILE__) + '/spec_helper.rb'
require 'fisheye-crucible/client'

describe FisheyeCrucible::Client do
  GOOD_USERNAME = 'gemtest'
  GOOD_PASSWORD = 'gemtest'

  before :each do
    servers = { :fisheye => 'http://sandbox.fisheye.atlassian.com' }

    @fc = FisheyeCrucible::Client.new(servers)
  end

  after :all do
    @fc.logout
  end

  it "should strip off the html from a full-response string" do
    string = '<response><string>gemtest:783:05a8fbecca9b5aa3f080eb425610b26e</string>\n</response>\n'
    new_string = @fc.strip_response_html_from string

    new_string.should_not include('<response><string>')
    new_string.should_not include('</string>\n</response>\n')
  end

  it "should strip off the html from a string without <response>" do
    string = '<string>gemtest:783:05a8fbecca9b5aa3f080eb425610b26e</string>\n'
    new_string = @fc.strip_response_html_from string

    new_string.should_not include('<response><string>')
    new_string.should_not include('</string>\n</response>\n')
  end

  it "should not strip off anything from a string without the html" do
    string = 'gemtest:783:05a8fbecca9b5aa3f080eb425610b26e'
    new_string = @fc.strip_response_html_from string

    new_string.should == string
  end

  context "login" do
    it "should login successfully with good credentials" do
      token = @fc.login(GOOD_USERNAME, GOOD_PASSWORD)
      token.should match(/^\w+:\d{3}:\w{32}$/)
    end
  end
end