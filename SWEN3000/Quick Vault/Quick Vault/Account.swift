//
//  Account.swift
//  Quick Vault
//
//  Created by administritor on 2019/5/8.
//  Copyright © 2019 KOD Inc. All rights reserved.
//

import Foundation
import UIKit

class Account {
    
    var userDefaults = UserDefaults.standard
    
    func setusername (value: String){
        userDefaults.set(value, forKey: "Username")
    }
    func getusername () -> String {
        return userDefaults.string(forKey: "Username") ?? ""
    }
    
    func setpassword (value: String){
        userDefaults.set(value, forKey: "Password")
    }
    func getpassword () -> String {
        return userDefaults.string(forKey:"Password") ?? ""
    }
    func changePassword(oldpassword:String, newpassword:String) -> Bool {
        if oldpassword != userDefaults.string(forKey: "Password") {
            return false
            
        } else {
            setpassword(value: newpassword)
            return true
        }
    }
    func deleteUser() {
        userDefaults.removeObject(forKey: "Username")
        userDefaults.removeObject(forKey: "Password")
    }
    
    
}
