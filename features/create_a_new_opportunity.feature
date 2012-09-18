Feature: Buyer create a new auction
  As a buyer
  I want to create a auction
  So I can buy what I need

  Scenario: buyer creates a auction 
    Given a user exist and is logged in
    When I create a new auction
    Then the need should have been created
    And a supplier should not be able to "win it now"

  Scenario: buyer creates a quick winnable auction
    Given a user exist and is logged in
    When I create a new quick winnable auction 
    Then the need should have been created
    And a supplier should be able to "win it now"

  Scenario: creates an auction for favorites only
    Given a user exist and is logged in
    When I create a new auction for favorites only
    Then the need should have been created
    And only my favorites should see the opportunity

