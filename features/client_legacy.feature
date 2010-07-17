Feature: Client to the legacy API
  As a user
  I want to be able to call the legacy Fisheye/Crucible API
  So that I can find out information on my server
  
  @positive
  Scenario: fisheyeVersion (==fisheye_version)
    Given I have logged in
    When I call "fisheyeVersion"
    Then I should receive a "String"
      And that String should be in the form x.x.x  

  @positive
  Scenario: crucibleVersion (==crucible_version)
    Given I have logged in
    When I call "crucibleVersion"
    Then I should receive a "String"
      And that String should be in the form x.x.x

  @positive
  Scenario: listPaths (==list_paths_from)
    Given I have logged in
      And I have a list of repositories
    When I call "listPaths" for the first repository
    Then I should receive an "Array"
      And that Array should contain Strings

  Scenario Outline: Make method calls
    Given I have logged in
    When I call "<api_method>" with parameters "<parameters>"
    Then I should receive a "<return_type>"

  Scenarios: Calls return proper types
    | api_method        | parameters    | return_type   |
    | fisheyeVersion    |               | String        |
    | crucibleVersion   |               | String        |
    | listRepositories  |               | Array         |
    | listPaths         | 'antlr'       | Hash          |
    | getRevision       | 'antlr','BUILD.txt',5847| Hash|
