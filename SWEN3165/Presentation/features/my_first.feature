Feature: All Tests for Menu Tingz app
  
  Scenario: As a valid user I can log into my app
     When I see "Login"
     Then I press "Login"
     When I see "Username"
     Then I enter text "admin" into field with id "lusername"
     * I go back
     Then I enter text "123456" into field with id "lpassword"
     # INCORRECT PASSWORD RESULTS IN AN ERROR TOAST
     * I go back
     * I press "Login Now" 
     * I wait for 5 seconds
     * I should see "Restaurants List"

  #IT IS OBSERVED THAT THERE IS NOT OPTION FOR SIGNING OUT
  #THEREFORE DO NOT TEST BOTH LOGIN AND SIGN UP SCENARIOS

  #Scenario: As a new user I should be able to create a new account
  #  When I see "Sign Up"
  #  Then I press "Sign Up"
  #  When I see "Username"
  #  Then I enter text "otboss" into field with id "username"
  #  Then I enter text "password" into field with id "password"
  #  * I go back
  #  Then I enter text "password" into field with id "confirmpassword"
  #  * I go back
  #  * I wait for 2 seconds
  #  * I press "submit" 
  

  # NOW TESTING ADD ITEMS TO ORDERS
  Scenario: The app should allow the user to add items to their order
    When I see "Live Love Home"
    Then I touch the "Live Love Home" text  
    Then I should see "Live Love Home"  
    When I see "Pasta with Chicken"
    Then I touch the "Pasta with Chicken" text 
    When I see "My Orders"
    Then I touch the "ADD MORE" text
    When I see "Fresh Mush"
    Then I touch the "Fresh Mush" text
    When I see "Rice With Pork"
    Then I touch the "Rice With Pork" text
    #THE CART SHOULD NOW HAVE MULTIPLE ITEMS
  #
  # NOW TESTING REMOVE ITEM FROM ORDERS
  Scenario: The app should allow the user to remove items from their order
    When I see "Live Love Home"
    Then I touch the "Live Love Home" text  
    Then I should see "Live Love Home"  
    When I see "Pasta with Chicken"
    Then I touch the "Pasta with Chicken" text 
    When I see "My Orders"
    Then I touch the "REMOVE" text

  # NOW TESTING ORDER PLACEMENT
  Scenario: Users should be allowed to place orders within the app
    When I see "Live Love Home"
    Then I touch the "Live Love Home" text
    Then I should see "Live Love Home"
    When I see "Pasta with Chicken"
    Then I touch the "Pasta with Chicken" text
    When I see "MAKE ORDER"
    Then I touch the "MAKE ORDER" text
    When I see "Are you sure you want to place this order"
    Then I touch the "YES" text

  #NOW RUNNING FULL TEST
  Scenario: A complete test
    When I see "Live Love Home"
    Then I touch the "Live Love Home" text  
    Then I should see "Live Love Home"  
    When I see "Pasta with Chicken"
    Then I touch the "Pasta with Chicken" text 
    When I see "My Orders"
    Then I touch the "ADD MORE" text
    When I see "Fresh Mush"
    Then I touch the "Fresh Mush" text
    When I see "Rice With Pork"
    Then I touch the "Rice With Pork" text
    # NOW TESTING REMOVE ITEM FROM ORDERS
    Then I touch the "ADD MORE" text
    When I see "Live Love Home"
    Then I touch the "Live Love Home" text  
    Then I should see "Live Love Home"
    When I see "Pasta with Chicken"
    Then I touch the "Pasta with Chicken" text 
    When I see "My Orders"
    Then I touch the "REMOVE" text
    # NOW TESTING ORDER PLACEMENT   
    When I see "MAKE ORDER"
    Then I touch the "MAKE ORDER" text
    When I see "Are you sure you want to place this order"
    Then I touch the "YES" text

  Scenario: checking out with an empty cart
    # It is obsevered that no error is thrown when checking out with an empty cart
    When I see "Live Love Home"
    Then I touch the "Live Love Home" text  
    Then I should see "Live Love Home"  
    When I see "Pasta with Chicken"
    Then I touch the "Pasta with Chicken" text 
    When I see "My Orders"
    Then I touch the "REMOVE" text  
    Then I touch the "MAKE ORDER" text
    When I see "Are you sure you want to place this order"
    Then I touch the "YES" text    
  
