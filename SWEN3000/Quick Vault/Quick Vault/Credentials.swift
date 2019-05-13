//
//  Credentials.swift
//  Quick Vault
//
//  Created by administritor on 2019/5/13.
//  Copyright © 2019 KOD Inc. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class Credentials: Object { 
    dynamic var title: String? = nil
    dynamic var username: String? = nil
    dynamic var password: String? = nil
    
   convenience init(title: String?, username: String?, password: String?) {
        self.init()
        self.title = title
        self.username = username
        self.password = password
    }
}
