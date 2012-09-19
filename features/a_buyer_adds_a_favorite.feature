Feature: A buyer adds a seller to their list of favorite suppliers

  Scenario: A buyer adds a seller as a favorite supplier
    Given a seller exists called "Boston Bus"
    And I am logged in as a buyer called "New York Bus"
    When I add that seller as one of my favorite suppliers
    Then that seller should be in my list of favorite suppliers
  
  Scenario: A buyer adds a guest company as a favorite supplier
  
  Scenario: A buyer adds an unknown company as a favorite supplier
