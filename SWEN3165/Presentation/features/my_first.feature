Feature: Login feature

  Scenario: As a valid user I can log into my app
    When I see "Sign Up"
    Then I press "Sign Up"
    When I see "Username"
    Then I enter text "otboss" into field with id "username"
    Then I enter text "password" into field with id "password"
    * I go back
    Then I enter text "password" into field with id "confirmpassword"
    * I go back
    * I wait for 2 seconds
    * I press "submit" 
    
    

  # Scenario: Login
  #   When I see "Login"
  #   Then I press "Login"
  #   When I see "Username"
  #   Then I enter text "otboss" into field with id "lusername"
  #   When I see "Password"
  #   Then I enter text "password" into field with id "lpassword"
  #   * I press "Login"
    
    

  Scenario: Purchasing pasta chicken
    When I see "Live Love Home"
    Then I press "Live Love Home"
    * I should see "Live Love Home"
    * I wait for 2 seconds
    When I see "Pasta with Chicken"
    Then I press "Pasta with Chicken"
    * I press "MAKE ORDER" button
    When I see "Are you sure you want to place order"
    Then I press "YES"

   
   
  # Scenario: Adding three orders and removing one before check out
  #   When I see "Fresh Mush"
  #   Then I touch "Fresh Mush"  


  # Scenario: checking out with an empty cart
