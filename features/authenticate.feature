Feature:  Authenticate as a Fisheye/Crucible user
  As I Fisheye/Crucible user
  I want to be able to login
  So that I can programmatically interact with Fisheye and Crucible
  
  @negative
  Scenario: Login with a bad password
    Given a valid user, "gemtest" and password "gemtest1"
    When I login with that user's credentials
    Then I receive an authentication error

  @positive
  Scenario: Login as a valid user
    Given a valid user, "gemtest" and password "gemtest"
    When I login with that user's credentials
    Then I receive a token back from the server

  @positive
  Scenario: Logout from valid session
    Given I have logged in
    When I logout
    Then I should receive confirmation that I have logged out