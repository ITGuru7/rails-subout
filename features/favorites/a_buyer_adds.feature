Feature: A buyer adds a supplier to their list of favorites

  Scenario: A buyer adds a member company as a favorite supplier
    Given a supplier exists called "Boston Bus"
    And I am signed in as a buyer
    When I add that supplier as one of my favorite suppliers
    Then that supplier should receive a favorite invitation email 
    When the supplier accpets the invitation
    Then that supplier should be in my list of favorite suppliers

  Scenario: A buyer adds an unknown company as a favorite supplier
    Given I am signed in as a buyer
    When I try to add "Boston Bus" with email "thomas@bostonbus.com" as one of my favorite suppliers but don't find it
    And I add "Boston Bus" to my favorites as a new guest supplier with email "thomas@bostonbus.com"
    Then "thomas@bostonbus.com" should receive a new guest supplier invitation email 
    When the supplier accpets the invitation
    And fills out their supplier details
    Then that supplier should be in my list of favorite suppliers
