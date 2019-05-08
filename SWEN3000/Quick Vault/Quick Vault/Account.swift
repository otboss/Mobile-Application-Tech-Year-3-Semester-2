//
//  Account.swift
//  Quick Vault
//
//  Created by administritor on 2019/5/8.
//  Copyright © 2019 KOD Inc. All rights reserved.
//

import Foundation

class Account {
    static var username = ""
    static var password = "123"
    
    func setpassword (value: String){
        Account.password = value
    }
    func getpassword () -> String {
        return Account.password
    }
    
}
