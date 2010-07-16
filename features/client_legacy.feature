Feature: Client to the legacy API
  As a user
  I want to be able to call the legacy Fisheye/Crucible API
  So that I can find out information on my server
  
  Scenario: fisheyeVersion
    Given I have logged in
    When I call "fisheyeVersion"
    Then I should receive a "String"
      And that String should be in the form x.x.x  

  Scenario: crucibleVersion
    Given I have logged in
    When I call "crucibleVersion"
    Then I should receive a "String"
      And that String should be in the form x.x.x