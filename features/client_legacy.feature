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

  @positive
  Scenarios: Calls return proper types
    | api_method        | parameters                    | return_type   |
    | fisheyeVersion    |                               | String        |
    | crucibleVersion   |                               | String        |
    | listRepositories  |                               | Array         |
    | listPaths         | 'antlr'                       | Hash          |
    | listPaths         | 'antlr','tool'                | Hash          |
    | getRevision       | 'antlr','BUILD.txt',5847      | Hash          |
    | pathHistory       | 'antlr','BUILD.txt'           | Array         |
    | getChangeset      | 'antlr',5847                  | Hash          |
    | listChangesets    | 'antlr'                       | Hash          |
    | listChangesets    | 'antlr','tool'                | Hash          |
    | listChangesets    | 'antlr','tool',1              | Hash          |
    | listChangesets    | 'antlr','tool',1,'2008-07-05T07:08:16-07:00'| Hash|
    | listChangesets    | 'antlr','tool',1,'2008-07-05T07:08:16-07:00', '2009-07-05T07:08:16-07:00'| Hash  |
    | query             | 'antlr','select revisions from dir /tool' | Array |
    | query             | 'antlr','select revisions from dir /tool return path' | Array |
    | query             | 'antlr','select revisions from dir /tool return path as test' | Array |

  @negative
  Scenario Outline: Raise exceptions
    Given I have logged in
    When I call "<api_method>" with parameters "<parameters>"
    Then I should receive an exception of type "<exception_type>"

  Scenarios: Calls throw exception when passed invalid parameters
    | api_method        | parameters                    | exception_type  |
    | fisheyeVersion    | 'test'                        | ArgumentError   |
    | crucibleVersion   | 'test'                        | ArgumentError   |
    | listRepositories  | 'test'                        | ArgumentError   |
    | listPaths         | 'blahblahblah'                | FisheyeCrucible::Error |
    | listPaths         | 'antlr','blahblahblah'        | FisheyeCrucible::Error |
    | getRevision       | 'blahblahblah','BUILD.txt',5847  | FisheyeCrucible::Error |
    | getRevision       | 'antlr','blahblahblah',5847   | FisheyeCrucible::Error |
    | getRevision       | 'antlr','BUILD.txt',9999999   | FisheyeCrucible::Error |
    | getRevision       | 'antlr','BUILD.txt','blahblahblah'   | RestClient::InternalServerError |
    | pathHistory       | 'blahblahblah','BUILD.txt'    | FisheyeCrucible::Error |
    | pathHistory       | 'antlr','blahblahblah'        | FisheyeCrucible::Error |
    | pathHistory       | 'antlr',123456789             | FisheyeCrucible::Error |

