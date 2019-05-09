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
    static var username = ""
    static var password = ""
    
    func setpassword (value: String){
        Account.password = value
    }
    func getpassword () -> String {
        return Account.password
    }
    func changePassword(oldpassword:String, newpassword:String) -> Bool {
        if oldpassword != Account.password {
            return false
            
        } else {
            Account.password = newpassword
            return true
        }
    }
    
    
}
