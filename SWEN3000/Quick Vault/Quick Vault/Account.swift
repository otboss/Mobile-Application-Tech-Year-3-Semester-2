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

//manages a users information
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
        userDefaults.removeObject(forKey: "Secret")
        userDefaults.removeObject(forKey: "LoggingStatus")
        userDefaults.removeObject(forKey: "TimerErrVal")
        userDefaults.removeObject(forKey: "ExitStatus")
        userDefaults.removeObject(forKey: "LoggingAttemptStreak")
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
    func isThereaUser () -> Bool {
        return userDefaults.bool(forKey: "Secret")
    }
    func setUserPresent (value: Bool) {
        userDefaults.set(value, forKey: "Status")
    }
    func getUserPresent () -> Bool {
        return userDefaults.bool(forKey: "Status")
    }
    func setUserLoggingStatus (value: Bool) {
        userDefaults.set(value, forKey: "LoggingStatus")
    }
    func getUserLoggingStatus () -> Bool {
        return userDefaults.bool(forKey: "LoggingStatus")
    }
    func setUserTimerError (value: Int) {
        userDefaults.set(value, forKey: "TimerErrVal")
    }
    func getUserTimerError () -> Int {
        return userDefaults.integer(forKey: "TimerErrVal")
    }
    func setUserExitApp (value: Bool) {
        userDefaults.set(value, forKey: "ExitStatus")
    }
    func getUserExitApp () -> Bool {
        return userDefaults.bool(forKey: "ExitStatus")
    }
    func setUserConsecErrLogging (value: Int) {
        userDefaults.set(value, forKey: "LoggingAttemptStreak")
    }
    func getUserConsecErrLogging () -> Int {
        return userDefaults.integer(forKey: "LoggingAttemptStreak")
    }
    
    
}
