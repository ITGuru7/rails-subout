Feature: Sign in

  @wip @javascript
  Scenario: A user signs in
    Given a user exists with email: "thomas@bostonbus.com" and password: "password1"
    And I am on the sign in page
    When I fill in "Email" with "thomas@bostonbus.com"
    And I fill in "Password" with "password1"
    And I press "Sign in"
    Then I should see "Sign Out"
