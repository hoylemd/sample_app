Feature: Login

  Background:
    Given I am on the login page

  @smoke @skip
  Scenario: Normal login flow
    When I enter my username
    And I enter my password
    And I click "Log in"
    Then I should see a success flash
    And I should not see any error messages
    And I should be logged in
    And I should see my user profile
    When I click "Log Out"
    Then I should see "Log in"
    And I should not be logged in
    When I enter my username
    And I enter my password
    And I click "Log in"
    Then I should see a success flash
    And I should not see any error messages
    And I should be logged in

  @not_implemented
  Scenario: Log in as admin

  @not_implemented
  Scenario: Log in as unverified user

  @skip
  Scenario: Both login fields are present
    Then I should see a "Username" field
    And I should see a "Password" field