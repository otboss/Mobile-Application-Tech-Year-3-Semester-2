//
//  Credentials.swift
//  Quick Vault
//
//  Created by administritor on 2019/5/13.
//  Copyright © 2019 KOD Inc. All rights reserved.
//

import Foundation
import RealmSwift

//represents an instance of a record
let data = encryption(string: "", secret: "FiugQTgPNwCWUY,VhfmM4cKXTLVFvHFe")

@objcMembers class Credentials: Object {
    dynamic var title: String? = nil
    dynamic var username: String? = nil
    dynamic var password: Data = data

   convenience init(title: String?, username: String?, password: Data) {
        self.init()
        self.title = title
        self.username = username
        self.password = password
    }
}



