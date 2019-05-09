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
            
            _password.text = ""


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
                
                _password.text = ""

            }
        }
        
        

    }
    
    
  
    
}


class SignUpViewConstroller: UIViewController{
    
    @IBOutlet var _username: UITextField!
    
    @IBOutlet var _password1: UITextField!
    @IBOutlet var _password2: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    
    @IBAction func createAccount(_ sender: Any) {
        
        let password1 = _password1.text
        let password2 = _password2.text
        let username = _username.text
        
        if username == "" {
            
            errorPopUp(title: "Username", message: "Please enter a username")
            
            _password1.text = ""
            _password2.text = ""
            
            return
        } else if password1 == "" || password2 == "" {
            errorPopUp(title: "Password", message: "Password field is empty")
            
            _password1.text = ""
            _password2.text = ""
            
            return
        } else if password1 != password2 {
            errorPopUp(title: "Password", message: "Password mismatch")
            
            _password1.text = ""
            _password2.text = ""
            
            return
        } else {
            
            user.setpassword(value: password1!)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileStoryboard")
            self.show(vc!, sender: self)
        }
    }
    
    func errorPopUp (title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let acceptAlert = UIAlertAction(title: "Okay", style: .cancel)
        
        alert.addAction(acceptAlert)
        
        present(alert, animated: true, completion: nil)
    }
    
    
}


class Profile: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

