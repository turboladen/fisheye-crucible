require 'net/ping/tcp'

Given /^a valid user, "(\w+)" and password "(.+)"$/ do |user, password|
  @user = user
  @password = password
end

When /^I login with that user\'s credentials$/ do
  @login = lambda { @fc.login(@user, @password) }
  @login.should_not be_nil
end

Then /^I receive a token back from the server$/ do
  @token = @login.call
  @token.class.should.eql? 'String'
  @token.should match(/^\w+:\d{3,}:\w{32}$/)
end

Then /^I receive an authentication error$/ do
  @login.should raise_error(FisheyeCrucibleError)
end

Given /^I have logged in$/ do
  @fc.login 'gemtest', 'gemtest'
  @fc.instance_eval("@token").should_not be_nil
end

When /^I logout$/ do
  @logout = lambda { @fc.logout }
  @logout.should_not be_nil
end

Then /^I should receive confirmation that I have logged out$/ do
  result = @logout.call
  result.should be_true
end