Feature:  Authenticate as a Fisheye/Crucible user
  As I Fisheye/Crucible user
  I want to be able to login
  So that I can programmatically interact with Fisheye and Crucible
  
  Scenario: Login with a bad password
    Given a valid user, "gemtest" and password "gemtest1"
    When I login with that user's credentials
    Then I receive an authentication error

  Scenario: Login as a valid user
    Given a valid user, "gemtest" and password "gemtest"
    When I login with that user's credentials
    Then I receive a token back from the server