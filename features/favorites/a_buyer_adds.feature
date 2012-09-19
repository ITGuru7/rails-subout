Feature: A buyer adds a supplier to their list of favorites

  Scenario: A buyer adds a member company as a favorite supplier
    Given a supplier exists called "Boston Bus"
    And I am logged in as a buyer
    When I add that supplier as one of my favorite suppliers
    Then that supplier should be in my list of favorite suppliers
  
  Scenario: A buyer adds an unknown company as a favorite supplier
