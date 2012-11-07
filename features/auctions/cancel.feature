Feature: 
  As a buyer 
  I want to cancel an auction before the first bid 
  because I changed my mind about buying this thing.

  @wip @javascript
  Scenario: Cancel an opportunity
    Given I am signed in as a buyer
    And I have an auction
    When I cancel the auction
    Then the auction should be canceled

  #Scenario: Can't cancel after the first bid
    #Given that I am the owner of Hyannis Bus Company
    #And that my account is active
    #And I am on the dashboard
    #And I have created an opportunity
    #And I see that opportunity in my opportunities screen
    #And there is at least one bid
    #Then I should not be able to cancel it
