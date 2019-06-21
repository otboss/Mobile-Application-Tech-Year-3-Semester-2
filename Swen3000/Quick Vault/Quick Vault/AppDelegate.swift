//
//  AppDelegate.swift
//  Quick Vault
//
//  Created by administritor on 2019/5/8.
//  Copyright © 2019 KOD Inc. All rights reserved.
//

import UIKit
import LocalAuthentication


class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UITabBar.appearance().tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.applicationDidTimeout(notification:)), name: .appTimeout, object: nil)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("appTimeout"), object:  nil)
        
        user.setUserExitApp(value: true)
        user.setUserTimerError(value: errorTimer)
        

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
//        user.setUserLoggingStatus(value: loggingstatus)
//        user.setUserTimerError(value: errorTimer)
//        user.setUserExitApp(value: true)
        

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "signInNsignUp", bundle: nil)
        let initialViewController : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "StartPoint") as UIViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.applicationDidTimeout(notification:)), name: .appTimeout, object: nil)

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("appTimeout"), object:  nil)
        
        
    }
    
    @objc func applicationDidTimeout(notification: NSNotification) {
        
        let wind = UIApplication.shared.keyWindow;
        var vc = wind?.rootViewController;
        while (vc?.presentedViewController != nil)
        {
            vc = vc?.presentedViewController;
        }
        
        let topVC = vc
        
        if topVC is SignInViewController {
            print("signIn")
            return
        } else if topVC is SignUpViewConstroller {
            print("signUP")
            return
        } else {
        
        print("application timeout")
        
        if user.getTouchIDstatus() == true {
        
        let context:LAContext = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Touch ID to reopen application", reply: {(wasSuccessful, error) in
                if wasSuccessful {
                    //resume action


                }else {
                    DispatchQueue.main.sync {
                        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "signInNsignUp", bundle: nil)
                        let initialViewController : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "StartPoint") as UIViewController
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                        self.window?.rootViewController = initialViewController
                        self.window?.makeKeyAndVisible()
                    }
   
                }
            })
        }
        } else {
            AlertServices.userActivityCheckPassword() { (password) in
                if password == decryption(encryptedData: user.getpassword(), secret: user.getUserSecret()) {
                    //resume action
                }else {
                        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "signInNsignUp", bundle: nil)
                        let initialViewController : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "StartPoint") as UIViewController
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                        self.window?.rootViewController = initialViewController
                        self.window?.makeKeyAndVisible()
                }
            }

            
        }
    }
        
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
//    func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
//
//        if let nav = base as? UINavigationController {
//            return getTopViewController(base: nav.visibleViewController)
//
//        } else if let tab  = base as? UITabBarController, let selected = tab.selectedViewController {
//            return getTopViewController(base: selected)
//
//        } else if let presented = base?.presentedViewController {
//            return getTopViewController(base: presented)
//        }
//
//        return base
//    }

    

}


