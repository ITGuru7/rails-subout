Feature: A buyer adds a seller to their list of favorite suppliers

  #Scenario: A buyer adds another member company
    #Given a member company exists "Boston Bus" with an email "thomas@bostonbus.com" and logo "boston-bus-logo.gif"
    #Given I am logged in as a member company "New York Bus"
    #And I follow "favorites"
    #And I fill in "thomas@bostonbus.com"
    #Then I should see "Boston Bus Company"
    #And I press "Ok"
    #Then I should see "Boston Bus Company" in my favorites

  @wip
  Scenario: A buyer adds a seller as a favorite supplier
    Given a seller exists called "Boston Bus"
    And I am logged in as a buyer called "New York Bus"
    When I add that seller as one of my favorites
    Then the seller should be in my list of favorites

  
  Scenario: A buyer adds a guest company as a favorite supplier
  
  Scenario: A buyer adds an unknown company as a favorite supplier
