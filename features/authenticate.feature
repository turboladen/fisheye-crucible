Feature:  Authenticate as a Fisheye/Crucible user
  As I Fisheye/Crucible user
  I want to be able to login
  So that I can programmatically interact with Fisheye and Crucible
  
  Scenario: Login as anonymous
    Given a Fisheye/Crucible server
    When I login with no credentials
    Then I receive a token back from the server

  Scenario: Login as a valid user
    Given a valid user
    When I login with that user's credentials
    Then I receive a token back from the server