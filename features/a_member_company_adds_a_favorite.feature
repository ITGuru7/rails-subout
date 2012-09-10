Feature: A member company adds a favorite

  Scenario: A member company adds another member company
    Given a member company exists "Boston Bus" with an email "thomas@bostonbus.com" and logo "boston-bus-logo.gif"
    Given I am logged in as a member company "New York Bus"
    And I follow "favorites"
    And I fill in "thomas@bostonbus.com"
    Then I should see "Boston Bus Company"
    Then I should see "Boston Bus Company"'s logo
    And I press "Ok"
    Then I should see "Boston Bus Company" in my favorites

  Scenario: A member company adds another member company
    Given a member company exists called "Boston Bus"
    Given I am logged in as a member company "New York Bus"
    And I add "Boston Bus" as one of my favorites
    Then "Boston Bus" should be in my list of favorites

  
  Scenario: A member company adds a guest company
  
  Scenario: A member company adds an unknown company
