When /^I call "([^"]*)" with parameters "([^"]*)"$/ do |api_method, parameters|
  @method = lambda { eval("@fc.#{api_method}(#{parameters})") }
  @method.should_not be_nil
end

Then /^I should receive an? "([^"]*)"$/ do |result_type|
  result = @method.call
  result.class.should == eval("#{result_type}")
end

Then /^I should receive an exception of type "([^"]*)"$/ do |exception_type|
  result = @method.should raise_error(eval("#{exception_type}"))
end

Then /^that String should be in the form x\.x\.x$/ do
  @result.should match(/\d\.\d(\.\d)?/)
end

Then /^that Array should contain Strings$/ do
  @result.each do |r|
    r.class.should == eval('String')
  end
end

Given /^I have a list of repositories$/ do
  @repos = @fc.repositories
  @result.should_not be_empty
end
