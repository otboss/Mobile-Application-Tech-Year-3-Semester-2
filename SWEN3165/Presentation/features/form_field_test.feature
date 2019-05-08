
    Feature: Form Vulnurability Test

    Scenario: As a new user I should be able to create a new account
      When I see "Sign Up"
      Then I press "Sign Up"
      When I see "Username"
      Then I enter text "\"$" into field with id "username"
      Then I enter text "\"$" into field with id "password"
      * I go back
      Then I enter text "\"$" into field with id "confirmpassword"
      * I go back
      * I wait for 2 seconds
      * I press "submit"  
      * I wait for 5 seconds
      * I should see "Restaurants List"     
      * I go back
      When I see "Username"
      Then I go back
      When I see "Login"
      Then I press "Login"
      When I see "Username"
      Then I enter text "\"$" into field with id "lusername"
      * I go back
      Then I enter text "\"$" into field with id "lpassword"
      * I go back
      * I press "Login Now" 
      * I wait for 5 seconds
      * I should see "Restaurants List"    
    