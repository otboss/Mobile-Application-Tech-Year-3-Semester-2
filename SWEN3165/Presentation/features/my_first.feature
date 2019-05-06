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

  #######################
  #NOW TESTING PURCHASING
  #######################

  Scenario: Purchasing pasta chicken
    When I see "Live Love Home"
    Then I press "Live Love Home"
    * I should see "Live Love Home"
    * I wait for 2 seconds
    When I see "Pasta with Chicken"
    Then I touch the "Pasta with Chicken" text
    When I see "MAKE ORDER"
    * I touch the "MAKE ORDER" text
    When I see "Are you sure you want to place this order"
    Then I touch the "YES" text

   
   
  # Scenario: Adding three orders and removing one before check out
  #   When I see "Fresh Mush"
  #   Then I touch "Fresh Mush"  


  # Scenario: checking out with an empty cart
