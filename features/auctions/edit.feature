Feature: Edit an auction

  @javascript
  Scenario: I want to edit an opportunity I created
    Given I am signed in as a buyer
    And I have an auction
    And that no one has bid on my opportunity
    When I edit the auction
    Then the action should be updated
