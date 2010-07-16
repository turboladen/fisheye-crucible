When /^I call "([^"]*)"$/ do |api_method|
  @result = eval("@fc.#{api_method}")
end

Then /^I should receive an? "([^"]*)"$/ do |result_type|
  @result.class.should == eval("#{result_type}")
end

Then /^that String should be in the form x\.x\.x$/ do
  @result.should match(/\d\.\d(\.\d)?/)
end

Then /^that Array should contain Strings$/ do
  @result.each do |r|
    r.class.should == eval('String')
  end
end