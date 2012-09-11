Feature: Create a new opportunity
  As I am a user of KEPEA
  I want to create a opportunity
  So that other companies can bid on it

  Scenario: creating a opportunity for others to bid
    Given a user exist and logged in
    When I submit a new opportunity
    Then I should see "Opportunity has been created"

  Scenario: create a new opportunity for someone to buy it now
  Scenario: create a new opportunity for favorite only
