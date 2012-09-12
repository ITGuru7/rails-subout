Feature: Dashboard

  @wip
  Scenario: A user view recent events
    Given some events exists
    And a user exist and is logged in
    Then I should see recent events

