//
//  ViewController.swift
//  Quick Vault
//
//  Created by administritor on 2019/5/8.
//  Copyright © 2019 KOD Inc. All rights reserved.
//

import UIKit

var user = Account()

class SignInViewController: UIViewController {


    @IBOutlet var _password: UITextField!
    
    
    @IBOutlet var _signinbutton: UIButton!
    
    @IBOutlet var _createaccountlink: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func signInProcess(_ sender: Any) {

        let password = _password.text

        if ( password == ""){

            let alert = UIAlertController(title: "Alert", message: "Please enter a password", preferredStyle: .alert)

            let acceptAlert = UIAlertAction(title: "Okay", style: .cancel)

            alert.addAction(acceptAlert)

            present(alert, animated: true, completion: nil)


            return

        } else {

            if (user.getpassword() == password){
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileStoryboard")
                self.show(vc!, sender: self)

            } else {
                
                let alert = UIAlertController(title: "Error", message: "Incorrect password entered", preferredStyle: .alert)
                
                let acceptAlert = UIAlertAction(title: "Okay", style: .cancel)
                
                alert.addAction(acceptAlert)
                
                present(alert, animated: true, completion: nil)

            }
        }

    }
    
    
    
  
    
}


class SignUpViewConstroller: UIViewController{
    
//    @IBOutlet var _username: UITextField!
//
//    @IBOutlet var _password: UITextField!
//
//    @IBOutlet var _cpassword: UITextField!
//
//    @IBOutlet var submit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    @IBAction func signUp(_ sender: Any) {
//    }
//    
    
}


class Profile: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

