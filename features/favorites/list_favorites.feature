Feature: A buyer view thier list of favorite companies

  @javascript
  Scenario:
    Given panding
    Given I am signed in as a buyer
    And I have a supplier exists called "Boston Bus" in my favorite list
    When I go to my all my favorites list
    Then then I should see the supplier "Boston Bus" in the list
