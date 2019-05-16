//
//  Account.swift
//  Quick Vault
//
//  Created by administritor on 2019/5/8.
//  Copyright © 2019 KOD Inc. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Account {
    
    var userDefaults = UserDefaults.standard
    
    func setusername (value: String){
        userDefaults.set(value, forKey: "Username")
    }
    func getusername () -> String {
        return userDefaults.string(forKey: "Username") ?? ""
    }
    
    func setpassword (value: Data){
        userDefaults.set(value, forKey: "Password")
    }
    func getpassword () -> Data {
        return userDefaults.data(forKey:"Password")!
    }
    func changePassword(oldpassword:Data, newpassword:Data) -> Bool {
        if oldpassword != userDefaults.data(forKey: "Password") {
            return false
            
        } else {
            setpassword(value: newpassword)
            return true
        }
    }
    func deleteUser() {
        userDefaults.removeObject(forKey: "Username")
        userDefaults.removeObject(forKey: "Password")
        userDefaults.removeObject(forKey: "TouchIDStatus")
    }
    func setTouchIDstatus (value: Bool) {
        userDefaults.set(value, forKey: "TouchIDStatus")
    }
    func getTouchIDstatus () -> Bool {
        return userDefaults.bool(forKey: "TouchIDStatus") 
    }
    func setUserSecret (value: String) {
        userDefaults.set(value, forKey: "Secret")
    }
    func getUserSecret () -> String {
        return userDefaults.string(forKey: "Secret") ?? ""
    }
    
    
}
