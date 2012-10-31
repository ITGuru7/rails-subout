Feature: A supplier does a quick win

  Scenario: A supplier uses the 'win it now' button
    #see bellow
    Given pending
    Given a buyer exists "Boston Bus"
    And I am logged in as a member supplier "New York Bus"
    And that buyer has a quick winnable auction "Boston to New York Charter"
    When I view that opportunity
    Then I should see the win it now amount
    When I do a quick win on that opportunity
    Then the buyer should be notified that I won that auction
    And that opportunity should have me as the winner
    And bidding should be closed on that opportunity

  @javascript
  Scenario: A supplier bids below the win it now price
    Given a buyer exists "Boston Bus"
    And I am logged in as a member supplier "New York Bus"
    And that buyer has a quick winnable auction "Boston to New York Charter"
    When I bid on that opportunity with amount below the win it now price
    Then I should win that opportunity automatically
