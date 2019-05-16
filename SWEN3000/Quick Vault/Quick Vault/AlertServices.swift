//
//  AlertSeervices.swift
//  Quick Vault
//
//  Created by administritor on 2019/5/13.
//  Copyright © 2019 KOD Inc. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class AlertServices {
    
    private init()  {}
    
    static func errorPopUp (vc:UIViewController, title:String, message:String ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let acceptAlert = UIAlertAction(title: "Okay", style: .cancel)
        
        alert.addAction(acceptAlert)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func adding (vc:UIViewController, completion: @escaping (String?,String?,String?) -> Void) {
        
        let alert = UIAlertController(title: "Adding new Record", message: nil, preferredStyle: .alert)
        alert.addTextField {(field1) in
            field1.placeholder = "Title"
        }
        alert.addTextField { (field2) in
            field2.placeholder = "Username"
        }
        alert.addTextField{ (field3) in
            field3.placeholder = "Password"
        }
        
        let actionAdd = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let titleval = alert.textFields?[0].text,
                    let usernameval = alert.textFields?[1].text,
                    let passwordval = alert.textFields?[2].text
                else {return}
            
            let title = titleval == "" ? nil : titleval
            let username = usernameval == "" ? nil : usernameval
            let password = passwordval == "" ? nil : passwordval
            
            completion(title,username,password)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)

        
        alert.addAction(actionAdd)
        alert.addAction(actionCancel)
        vc.present(alert, animated: true)
    }
    
    static func updating (vc:UIViewController, database: Credentials, completion: @escaping (String?,String?,String?) -> Void) {

        
        let alert = UIAlertController(title: "Updating Record", message: nil, preferredStyle: .alert)
        alert.addTextField {(field1) in
            field1.text = database.title
        }
        alert.addTextField { (field2) in
            field2.text = database.username
        }
        alert.addTextField{ (field3) in
            field3.text = database.password
        }
        
        let actionAdd = UIAlertAction(title: "Update", style: .default) { (_) in
            guard let titleval = alert.textFields?.first?.text,
                let usernameval = alert.textFields?[1].text,
                let passwordval = alert.textFields?.last?.text
                else {return}
            
            let title = titleval == "" ? nil : titleval
            let username = usernameval == "" ? nil : usernameval
            let password = passwordval == "" ? nil : passwordval
            
            completion(title,username,password)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        
        alert.addAction(actionAdd)
        alert.addAction(actionCancel)
        vc.present(alert, animated: true)
    }
    
    static func passwordChange (vc:UIViewController, completion: @escaping (String) -> Void) {
        
        
        let alert = UIAlertController(title: "Updating Password", message: "Blank entry will not update password", preferredStyle: .alert)
        alert.addTextField {(field1) in
            field1.text = "Password"
        }
        
        let actionAdd = UIAlertAction(title: "Update", style: .default) { (_) in
            guard let passwordval = alert.textFields?.first?.text
                else {return}
            
            let password = passwordval == "" ? nil : passwordval
           
            completion(password ?? "Password")
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        
        alert.addAction(actionAdd)
        alert.addAction(actionCancel)
        vc.present(alert, animated: true)
    }
    
//    static func photoOptions (vc: UIViewController, completion: @escaping (UIImage?) -> Void) {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = (vc as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
//
//        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
//
//        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
//            if UIImagePickerController.isSourceTypeAvailable(.camera){
//                imagePickerController.sourceType = .camera
//                vc.present(imagePickerController, animated: true, completion: nil)
//            } else {
//                AlertServices.errorPopUp(vc: vc, title: "Camera", message: "Camera could not be launch")
//            }
//
//
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action:UIAlertAction) in
//            imagePickerController.sourceType = .photoLibrary
//            vc.present(imagePickerController, animated: true, completion: nil)
//
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
//        vc.present(actionSheet, animated: true, completion: nil)
//    }
    
    
}
