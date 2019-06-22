//
//  ViewController.swift
//  Quick Vault
//
//  Created by administritor on 2019/5/8.
//  Copyright © 2019 KOD Inc. All rights reserved.
//

import UIKit
import RealmSwift
import LocalAuthentication

var user = Account()
var currentCellNum = 0
var globalcredentialList: Results<Credentials>!
var showBiometrics = user.getTouchIDstatus()
var gradientLayer: CAGradientLayer!
var errorTimer = 0
var loggingIncorrect = user.getUserConsecErrLogging()
var loggingstatus = user.getUserLoggingStatus()



class SignInViewController: UIViewController, UITabBarDelegate, UITextFieldDelegate {


    @IBOutlet var _password: UITextField!
    
    
    @IBOutlet var _signinbutton: UIButton!
    
    @IBOutlet var _touchId: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        showBiometrics = user.getTouchIDstatus()
        
        //check if biometrics is enable by user
        if showBiometrics == true {
            _touchId.isHidden = false
            _signinbutton.isHidden = true
            _password.isHidden = true
        } else {
            _touchId.isHidden = true
        }
        
    }
    
    
    //crates a gradient color
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds

        gradientLayer.colors = [UIColor.init(red:0.18, green:0.80, blue:0.45, alpha:1.0).cgColor, UIColor.init(red:0.33, green:0.88, blue:0.74, alpha:1.0).cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGradientLayer()
        imageForBiometrics()
    }
    
    @IBAction func touchID(_ sender: Any) {
        if user.getUserExitApp() == true{
            if user.getUserLoggingStatus() == false {
                passwordErrorContinue()
            }
        }
        
        
        if errorTimer > 0 {
            
            user.setUserExitApp(value: false)
            let minutes = errorTimer / 60
            AlertServices.errorPopUp(vc: self, title: "Password", message: "You have " + String(minutes) + " minutes remaining before you can attempt to sign in again" )
        } else {
            
        user.setUserExitApp(value: false)
            
        let context:LAContext = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Touch ID for logging in", reply: {(wasSuccessful, error) in
                if wasSuccessful {
                    DispatchQueue.main.sync {
                        self.performSegue(withIdentifier: "gotomain", sender: Any?.self)
                    }
                    
                    loggingstatus = true
                    loggingIncorrect = 0
                    user.setUserLoggingStatus(value: loggingstatus)
                    user.setUserConsecErrLogging(value: loggingIncorrect)
                    
                }else {
                    DispatchQueue.main.sync {
                        self._touchId.isHidden = true
                        self._signinbutton.isHidden = false
                        self._password.isHidden = false
                    }
                    loggingIncorrect += 1
                    user.setUserConsecErrLogging(value: loggingIncorrect)
                    
                    if loggingIncorrect >= 4 {
                        self.passwordErrorOccured()
                        loggingstatus = false
                        user.setUserLoggingStatus(value: loggingstatus)
                    
                        
                    }
                }
            })
        }
    }
    }
    
    //select which image to show for biometrics base on user device
    func imageForBiometrics () {
        
        let context = LAContext()
        
        var error: NSError?
        
        if context.canEvaluatePolicy( LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            if (context.biometryType == LABiometryType.faceID) {
                // Device support Face ID
                _touchId.setImage(UIImage(named: "icons8-face-id-50"), for: .normal)
            } else if context.biometryType == LABiometryType.touchID {
                // Device supports Touch ID
                _touchId.setImage(UIImage(named: "icons8-fingerprint-50"), for: .normal)
            } else {
                // Device has no biometric support
            }
        }
    }
    
    @IBAction func signInProcess(_ sender: Any) {
        
        let password = _password.text
        
        if user.getUserExitApp() == true{
            if user.getUserLoggingStatus() == false {
                passwordErrorContinue()
            }
        }
        
        if errorTimer > 0 {
            
            user.setUserExitApp(value: false)
            let minutes = errorTimer / 60
            AlertServices.errorPopUp(vc: self, title: "Password", message: "You have " + String(minutes) + " minutes remaining before you can attempt to sign in again" )
        }else {
            
            user.setUserExitApp(value: false)
            
        if ( password == ""){
            
            AlertServices.errorPopUp(vc: self,title: "Alert", message: "Please enter a password")


            
            _password.text = ""
        
            return

        } else {
            if (!user.getUserPresent()) {
                
                AlertServices.errorPopUp(vc: self, title: "Account", message: "No account found on device")
            }
            else if (decryption(encryptedData: user.getpassword(), secret: user.getUserSecret()) == password ){

                    self.performSegue(withIdentifier: "gotomain", sender: Any?.self)
                
                    loggingstatus = true
//                    user.setUserTimerError(value: errorTimer)
                    user.setUserLoggingStatus(value: loggingstatus)
                    loggingIncorrect = 0
                    user.setUserConsecErrLogging(value: loggingIncorrect)
            

                


            } else {


                AlertServices.errorPopUp(vc: self, title: "Error", message: "Incorrect password entered")

                _password.text = ""
                
                
                loggingIncorrect += 1
                user.setUserConsecErrLogging(value: loggingIncorrect)
                
                if loggingIncorrect >= 4 {
                    self.passwordErrorOccured()
                    loggingstatus = false
                    user.setUserLoggingStatus(value: loggingstatus)


                    
                }


            }
        }
        }
        
    }
    
    var timerError: Timer?
    

    func startTimerForPasswordErr () {
        DispatchQueue.main.async {
            self.timerError =  Timer.scheduledTimer(timeInterval: 60 , target: self, selector: #selector(self.passwordErrorChecker), userInfo: nil, repeats: true)
        }
        
    }


    @objc func passwordErrorChecker () {
        errorTimer -= 60
        user.setUserTimerError(value: errorTimer)

        if errorTimer <= 0 {
            self.timerError?.invalidate()
            timerError = nil
            loggingstatus = true
            user.setUserLoggingStatus(value: loggingstatus)
            loggingIncorrect = 0
        }
    }

    func passwordErrorOccured () {
        errorTimer = 3600
        startTimerForPasswordErr()
    }
    
    func passwordErrorContinue () {
        errorTimer = user.getUserTimerError()
        startTimerForPasswordErr()
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}


class SignUpViewConstroller: UIViewController, UITextFieldDelegate{
    
    @IBOutlet var _username: UITextField!
    
    @IBOutlet var _password1: UITextField!
    @IBOutlet var _password2: UITextField!
    @IBOutlet var _passwordHelper: UILabel!
    var isPasswordValid = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor(red:0.29, green:0.08, blue:0.55, alpha:1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGradientLayer()
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        //        gradientLayer.colors = [UIColor.blue.cgColor, UIColor.purple.cgColor]
        gradientLayer.colors = [UIColor.init(red:0.18, green:0.80, blue:0.45, alpha:1.0).cgColor, UIColor.init(red:0.33, green:0.88, blue:0.74, alpha:1.0).cgColor]
        
        //        self.view.layer.addSublayer(gradientLayer)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }

    @IBAction func _passwordEditing(_ sender: Any) {
        textFieldDidChange(_password1)
    }
    
    @IBAction func _passwordEditingEnd(_ sender: Any) {
        _passwordHelper.attributedText = NSMutableAttributedString(string: "")
        _passwordHelper.backgroundColor = UIColor(red:0.18, green:0.80, blue:0.45, alpha:1.0)
    }
    
    
    @IBAction func secondPasswordEditing(_ sender: Any) {
        checkPasswordEquality()
    }
    
    @IBAction func secondPasswordEditingEnd(_ sender: Any) {
        _passwordHelper.attributedText = NSMutableAttributedString(string: "")
        _passwordHelper.backgroundColor = UIColor(red:0.18, green:0.80, blue:0.45, alpha:1.0)
    }
    
    func checkPasswordEquality (){
        if _password1.text == _password2.text {
            let attrStr = NSMutableAttributedString ( string: "Passwords are the same", attributes: [ .foregroundColor: UIColor.green] )
            _passwordHelper.attributedText = attrStr
            _passwordHelper.backgroundColor = UIColor(red:0.06, green:0.66, blue:0.51, alpha:1.0)
        } else {
            let attrStr = NSMutableAttributedString ( string: "Passwords are not the same", attributes: [ .foregroundColor: UIColor.red] )
            _passwordHelper.attributedText = attrStr
            _passwordHelper.backgroundColor = UIColor(red:0.06, green:0.66, blue:0.51, alpha:1.0)
        }
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        let attrStr = NSMutableAttributedString (
            string: "Password must be at least 8 characters but less than 17 characters, and contain at least one upper case letter, one lower case letter and one number .",

            attributes: [ .foregroundColor: UIColor.darkGray]
        )
        
        if let txt = _password1.text {
            isPasswordValid = true
            attrStr.addAttributes(setupAttributeColor(if: (txt.count >= 8)),
                                  range: findRange(in: attrStr.string, for: "at least 8 characters"))
            attrStr.addAttributes(setupAttributeColor(if: (txt.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil)),
                                  range: findRange(in: attrStr.string, for: "one upper case letter"))
            attrStr.addAttributes(setupAttributeColor(if: (txt.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil)),
                                  range: findRange(in: attrStr.string, for: "one lower case letter"))
            attrStr.addAttributes(setupAttributeColor(if: (txt.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil)),
                                  range: findRange(in: attrStr.string, for: "one number"))
            attrStr.addAttributes(setupAttributeColor(if: (txt.count < 19)),
                                  range: findRange(in: attrStr.string, for: "less than 17 characters"))
        } else {
            isPasswordValid = false
        }
        
        _passwordHelper.attributedText = attrStr
        _passwordHelper.backgroundColor = UIColor(red:0.06, green:0.66, blue:0.51, alpha:1.0)
    }
    
    func setupAttributeColor(if isValid: Bool) -> [NSAttributedString.Key: Any] {
        if isValid {
            return [NSAttributedString.Key.foregroundColor: UIColor.green]
        } else {
            isPasswordValid = false
            return [NSAttributedString.Key.foregroundColor: UIColor.red]
        }
    }
    
    func findRange(in baseString: String, for substring: String) -> NSRange {
        if let range = baseString.localizedStandardRange(of: substring) {
            let startIndex = baseString.distance(from: baseString.startIndex, to: range.lowerBound)
            let length = substring.count
            return NSMakeRange(startIndex, length)
        } else {
            print("Range does not exist in the base string.")
            return NSMakeRange(0, 0)
        }
    }
    
    
    @IBAction func createAccount(_ sender: Any) {
        
        let password1 = _password1.text
        let password2 = _password2.text
        let username = _username.text
        
        if username == "" {
            
            AlertServices.errorPopUp(vc: self, title: "Username", message: "Please enter a username")
            
            _password1.text = ""
            _password2.text = ""
            
            return
        } else if password1 == "" || password2 == "" {
            AlertServices.errorPopUp(vc: self, title: "Password", message: "Password field is empty")
            
            _password1.text = ""
            _password2.text = ""
            
            return
        } else if password1 != password2 {
            AlertServices.errorPopUp(vc: self, title: "Password", message: "Password mismatch")
            
            _password1.text = ""
            _password2.text = ""
            
            return
        } else if isPasswordValid == false {
            AlertServices.errorPopUp(vc: self, title: "Password", message: "Password quality is weak. Try again")
            
            _password1.text = ""
            _password2.text = ""
            
        } else {
            
           
            //previous user details are deleted
            user.deleteUser()
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
            //if a picture is in the document directory its deleted
            let fileManager = FileManager.default
            let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("UserImage.png")
            if fileManager.fileExists(atPath: imagePath) {
                try! fileManager.removeItem(atPath: imagePath)
            }
            
            //users info is stored
            let secret = randomString(length: 32)
            user.setUserSecret(value: secret)
            
            let encrypt = encryption(string: password1!, secret: user.getUserSecret())
            user.setpassword(value: encrypt)
            user.setusername(value: username!)
            user.setTouchIDstatus(value: false)
            user.setUserPresent(value: true)
            user.setUserLoggingStatus(value: true)
            user.setUserConsecErrLogging(value: 0)
            
            performSegue(withIdentifier: "createandgotomain", sender: Any?.self)
            
//            NotificationCenter.default.addObserver(UIApplication.self, selector: #selector(AppDelegate.applicationDidTimeout(notification:)), name: .appTimeout, object: nil)

        }
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
}


class passwords : UITableViewController, UISearchBarDelegate, UITextFieldDelegate {
    
    var searchItems = [String]()
    var searching = false
    @IBOutlet var Search: UISearchBar!
    var credentialList: Results<Credentials>!
    var notificationToken: NotificationToken?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = RealmService.shared.realm
        credentialList = realm.objects(Credentials.self)
        notificationToken = realm.observe{ (notification, realm) in
            self.tableView.reloadData()
        }
        
        RealmService.shared.observeRealmErrors(in: self) { (error) in
            print(error ?? "NO error detected")
        }
        globalcredentialList = credentialList
        
        removeEmptyCells()
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = UIColor(red:0.18, green:0.80, blue:0.45, alpha:1.0)
        tableView.reloadData()
    }
    
    func removeEmptyCells() {
        if credentialList.count == 0 {
            tableView.separatorStyle = .none
        } else {
            tableView.tableFooterView = UIView(frame: .zero)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationToken?.invalidate()
        RealmService.shared.stopObservingErrors(vc: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchItems.count
        } else {
            return credentialList.count
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1")
        
        cell?.backgroundColor = UIColor(red:0.49, green:0.93, blue:0.62, alpha:1.0)

        
        if searching {
            cell?.textLabel?.text = searchItems[indexPath.row]
            cell?.textLabel?.textAlignment = .center
            cell?.textLabel?.textColor = UIColor.darkGray
            
        } else {

            cell?.textLabel?.text = credentialList[indexPath.row].title
            cell?.textLabel?.textAlignment = .center
            cell?.textLabel?.textColor = UIColor.darkGray
        }
        
        cell?.selectionStyle = .none
        
        return cell!
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        
        
        if  searching {
            let cell = tableView.cellForRow(at: indexPath)
            let labelContent = cell?.textLabel?.text ?? ""
            let place = getCredentialsWhileSearching(value: labelContent)
            let credential = credentialList[place]
            RealmService.shared.delete(credential)
            
        } else {
            let credential = credentialList[indexPath.row]
            RealmService.shared.delete(credential)
            self.tableView.reloadData()
        }

    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searching {
            let cell = tableView.cellForRow(at: indexPath)
            let labelContent = cell?.textLabel?.text
            currentCellNum = getCredentialsWhileSearching(value: labelContent ?? "")
            print(indexPath.row.description)
        } else {
        currentCellNum = indexPath.row
        }
    }
    

    
    @IBAction func add(_ sender: Any) {
        
        AlertServices.adding(vc: self) { (title,username,password) in
            print(title ?? "",username ?? "",password ?? "")
            
            let enPassword = encryption(string: password!, secret: user.getUserSecret())
            let newCredential = Credentials(title: title, username: username, password: enPassword)
            RealmService.shared.create(newCredential)
            self.tableView.reloadData()
            
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let titles = getTitles()
        searchItems = titles.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased() })
        print(searchItems)
        searching = true
        tableView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
        view.endEditing(true)
    }
    
    func getTitles () -> [String] {
        var dic : [String] = [""]
        let num = credentialList.count
        var cur = 0
        
        dic.removeAll()
        while cur < num {
            dic.append(credentialList[cur].title ?? "No Title")
            cur += 1
        }
        
        return dic
    }
    
    func getCredentialsWhileSearching (value: String) -> Int {
        let name = getTitles()
        var position = 0
        
        if name.contains(value) {
            position = name.firstIndex(of: value) ?? 0
        }
        return position
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
}


class listInfo : UITableViewController, UITextFieldDelegate {
    
    var notificationToken: NotificationToken?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        let realm = RealmService.shared.realm
        notificationToken = realm.observe{ (notification, realm) in
            self.tableView.reloadData()
        }
        
        RealmService.shared.observeRealmErrors(in: self) { (error) in
            print(error ?? "NO error detected")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = UIColor(red:0.18, green:0.80, blue:0.45, alpha:1.0)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationToken?.invalidate()
        RealmService.shared.stopObservingErrors(vc: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "cell1") as! cells
        
        if indexPath.row == 0 {
            cell1._text.text = globalcredentialList[currentCellNum].title
            cell1._text.textAlignment = .center
            cell1._text.textColor = UIColor.darkGray
            cell1._text.backgroundColor = UIColor(red:0.49, green:0.93, blue:0.62, alpha:1.0)

        } else if indexPath.row == 1 {
            cell1._text.text = globalcredentialList[currentCellNum].username
            cell1._image.image = UIImage(named: "icons8-name-20")
            cell1._text.backgroundColor = UIColor(red:0.49, green:0.93, blue:0.62, alpha:1.0)

        } else if indexPath.row == 2 {
            cell1._text.text = decryption(encryptedData: globalcredentialList[currentCellNum].password, secret: user.getUserSecret())
            cell1._image.image = UIImage(named: "icons8-lock-20")
            cell1._text.backgroundColor = UIColor(red:0.49, green:0.93, blue:0.62, alpha:1.0)

        }
        
        cell1.backgroundColor = UIColor(red:0.49, green:0.93, blue:0.62, alpha:1.0)
        cell1.selectionStyle = .none
        

        return cell1
    }

   
    @IBAction func Editing(_ sender: Any) {
        
        let credential = globalcredentialList[currentCellNum]

        AlertServices.updating(vc: self, database: credential) { (title,username,password) in
        print(title ?? "",username ?? "",password ?? "")
            
            let enPassword = encryption(string: password!, secret: user.getUserSecret())
            let dic: [String: Any?] = ["title": title, "username": username, "password": enPassword]
            RealmService.shared.update(credential, dictionary: dic)
            self.tableView.reloadData()
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

   
}

class cells : UITableViewCell {
    
    @IBOutlet var _image: UIImageView!
    @IBOutlet var _text: UITextView!
    
    
}


class profile : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet var _usernameBtn: UITextField!
    @IBOutlet var _image: UIImageView!
    var imagePickerController : UIImagePickerController!
    
    @IBOutlet var _switch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getProfileName()
        getImage(imageName: "UserImage.png")
        
        if user.getTouchIDstatus() == true {
            _switch.setOn(true, animated: true)
        } else {
            _switch.setOn(false, animated: true)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGradientLayer()
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.init(red:0.18, green:0.80, blue:0.45, alpha:1.0).cgColor, UIColor.init(red:0.33, green:0.88, blue:0.74, alpha:1.0).cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    func getProfileName () {
        _usernameBtn.text = user.getusername()
        _usernameBtn.textColor = UIColor.darkGray
        _usernameBtn.textAlignment = .center
        _usernameBtn.allowsEditingTextAttributes = false
        
    }
    
    @IBAction func changePassword(_ sender: Any) {
        AlertServices.passwordChange(vc: self) { (password) in
            if password != "" {
                user.setpassword(value: encryption(string: password, secret: user.getUserSecret()) )
            }
        }
    }
    
    @IBAction func DeletionofAccount(_ sender: Any) {
        user.deleteUser()
        user.setUserPresent(value: false)
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        deleteImage(imageName: "UserImage.png")
        
        let viewController:UIViewController = UIStoryboard(name: "signInNsignUp", bundle: nil).instantiateViewController(withIdentifier: "newAccount") as UIViewController
        
        self.present(viewController, animated: false, completion: nil)
        
    }
    
    @IBAction func takePicture(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self

        let actionSheet = UIAlertController(title: "Profile Image", message: "Adding a Picture", preferredStyle: .actionSheet)
        
        //commited area is for the implemetation of the camera but it wasn't working properly

//        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
//            if UIImagePickerController.isSourceTypeAvailable(.camera){
//                imagePickerController.sourceType = .camera
//                imagePickerController.cameraDevice = .front
//                imagePickerController.allowsEditing = false
//                self.present(imagePickerController, animated: true, completion: nil)
//            } else {
//                AlertServices.errorPopUp(vc: self, title: "Camera", message: "Camera could not be launch")
//            }
//
//
//        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func savePicture(_ sender: Any) {
        saveImage(imageName: "UserImage.png")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey:Any]) {
        if let image = info [UIImagePickerController.InfoKey.editedImage] as? UIImage {
//            imagePickerController.dismiss(animated: true, completion: nil)
//            _image.image = info[.originalImage] as? UIImage
            _image.image = image
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveImage(imageName: String){
        //create an instance of the FileManager
        let fileManager = FileManager.default
        //get the image path
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        //get the image we took with camera
        let image = _image.image
        //get the PNG data for this image
        let data = image?.pngData()
        //store it in the document directory
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)

    }
    
    func deleteImage(imageName: String){

        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath) {
            try! fileManager.removeItem(atPath: imagePath)
        }
        
    }
    
    func getImage(imageName: String){
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
//            makeImageCircular(_image: _image)
            _image.image = UIImage(contentsOfFile: imagePath)
        }else{
            //no image
        }
    }

    
    @IBAction func _touchIDToggle(_ sender: UISwitch) {
        
        if isDeviceSupportedforAuth() == true {
            if sender.isOn == true {
                let context:LAContext = LAContext()
                
                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
                    context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Enabling Biometrics for easier access", reply: {(wasSuccessful, error) in
                        if wasSuccessful {
                            showBiometrics = true
                            DispatchQueue.main.sync {
                                user.setTouchIDstatus(value: true)
                                sender.setOn(true, animated: true)
                            }
                            
                        }else {
                            showBiometrics = false
                            DispatchQueue.main.sync {
                                sender.setOn(false, animated: true)
                                user.setTouchIDstatus(value: false)
                            }
                            
                        }
                    })
                }
            } else {
                showBiometrics = false
                //            DispatchQueue.main.sync {
                sender.setOn(false, animated: true)
                user.setTouchIDstatus(value: false)
                //            }
                
            }
            
        } else {
            AlertServices.errorPopUp(vc: self, title: "Biometrics", message: "Your phone does not support biometrics or it is not enabled")
        }
        

    }
    
    func isDeviceSupportedforAuth () -> Bool {
        let  context = LAContext()
        var policy: LAPolicy?
        policy = .deviceOwnerAuthentication
        var err: NSError?
        guard context.canEvaluatePolicy(policy!, error: &err) else
        {
            return false
        }
        return true
    
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    

}




    






