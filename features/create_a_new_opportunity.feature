Feature: Buyer create a new auction
  As a buyer
  I want to create a auction
  So I can buy what I need

  Scenario: buyer creates a auction 
    Given a user exist and is logged in
    When I create a new auction
    Then the need should have been created
    Then a supplier should not be able to "win it now"

  @wip
  Scenario: buyer creates a quick winable auction
    Given a user exist and is logged in
    When I create a new quick winable auction 
    Then the item should have been created
    Then a supplier should be able to "win it now"

  Scenario: creates an auction for favorites only
    Given a user exist and is logged in
    When I create a new auction for favorites only
    Then the item should have been created
    And only my favorites should see the opportunity

