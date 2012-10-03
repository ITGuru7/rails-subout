Feature: A supplier bids

  Scenario: A member supplier bids on an opportunity
    Given a buyer exists "Boston Bus"
    And I am logged in as a member supplier "New York Bus"
    And that buyer has an auction "Boston to New York Charter"
    When I bid on that opportunity
    Then I should see my bid on that opportunity
    And the buyer should be notified about my bid
