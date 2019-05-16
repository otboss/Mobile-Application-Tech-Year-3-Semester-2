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
var showBiometrics = false

class SignInViewController: UIViewController, UITabBarDelegate {


    @IBOutlet var _password: UITextField!
    
    
    @IBOutlet var _signinbutton: UIButton!
    
    @IBOutlet var _touchId: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        showBiometrics = user.getTouchIDstatus()
        if showBiometrics == true {
            _touchId.isHidden = false
            _signinbutton.isHidden = true
            _password.isHidden = true
        } else {
            _touchId.isHidden = true
        }
        
    }
    
    @IBAction func touchID(_ sender: Any) {
        let context:LAContext = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Touch ID for logging in", reply: {(wasSuccessful, error) in
                if wasSuccessful {
                    self.performSegue(withIdentifier: "gotomain", sender: Any?.self)
                    print("Successful")
                }else {
                    self._touchId.isHidden = true
                    self._signinbutton.isHidden = false
                    self._password.isHidden = false
                    print("Not Successful")
                }
            })
        }
    }
    
    @IBAction func signInProcess(_ sender: Any) {

        let password = _password.text

        if ( password == ""){
            
            AlertServices.errorPopUp(vc: self,title: "Alert", message: "Please enter a password")


            
            _password.text = ""
        
            return

        } else {
            
            if user.getpassword().isEmpty {
                
                AlertServices.errorPopUp(vc: self, title: "Account", message: "No account found on device")
            }
//encryption affected
//            else if (user.getpassword() == password){
//
//                 self.performSegue(withIdentifier: "gotomain", sender: Any?.self)
//
//
//            } else {
//
//
//                AlertServices.errorPopUp(vc: self, title: "Error", message: "Incorrect password entered")
//
//                _password.text = ""
//
//
//            }
        }
    }
    
        
}


class SignUpViewConstroller: UIViewController{
    
    @IBOutlet var _username: UITextField!
    
    @IBOutlet var _password1: UITextField!
    @IBOutlet var _password2: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
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

            
            print("calling back function")
            
            let val = decryption(encryptedData: user.getpassword(), secret: user.getUserSecret())
            print(val)
            
            performSegue(withIdentifier: "createandgotomain", sender: Any?.self)

        }
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    
}


class passwords : UITableViewController, UISearchBarDelegate {
    
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
            print("reload")
        }
        
        RealmService.shared.observeRealmErrors(in: self) { (error) in
            print(error ?? "NO error detected")
        }
        globalcredentialList = credentialList
        
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
        
        cell?.backgroundColor = UIColor(red: 0.6902, green: 0.4549, blue: 0.9294, alpha: 1.0)
        
        tableView.backgroundColor = UIColor(red:0.58, green:0.51, blue:0.91, alpha:1.0)

        
        if searching {
            cell?.textLabel?.text = searchItems[indexPath.row]
            
        } else {

            cell?.textLabel?.text = credentialList[indexPath.row].title
        }
        
        
        
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
            
            
            let newCredential = Credentials(title: title, username: username, password: password)
            RealmService.shared.create(newCredential)
            self.tableView.reloadData()
            print("add reload")
            
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
    
    

    
    
}


class listInfo : UITableViewController {
    
    var notificationToken: NotificationToken?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = RealmService.shared.realm
        notificationToken = realm.observe{ (notification, realm) in
            self.tableView.reloadData()
        }
        
        RealmService.shared.observeRealmErrors(in: self) { (error) in
            print(error ?? "NO error detected")
        }
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1")
        
        cell?.backgroundColor = UIColor(red: 0.6902, green: 0.4549, blue: 0.9294, alpha: 1.0)
        tableView.backgroundColor = UIColor(red:0.58, green:0.51, blue:0.91, alpha:1.0)

        
        if indexPath.row == 0 {
            cell?.textLabel?.text = globalcredentialList[currentCellNum].title
        } else if indexPath.row == 1 {
            cell?.textLabel?.text = globalcredentialList[currentCellNum].username
        } else if indexPath.row == 2 {
            cell?.textLabel?.text = globalcredentialList[currentCellNum].password
        }
        
        return cell!
    }

   
    

    
    
    @IBAction func Editing(_ sender: Any) {
        
        let credential = globalcredentialList[currentCellNum]

        AlertServices.updating(vc: self, database: credential) { (title,username,password) in
        print(title ?? "",username ?? "",password ?? "")
            
            let dic: [String: Any?] = ["title": title, "username": username, "password": password]
            RealmService.shared.update(credential, dictionary: dic)
            self.tableView.reloadData()
        }

    }

   
}


class profile : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet var _usernameBtn: UITextField!
    @IBOutlet var _image: UIImageView!
    var imagePickerController : UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getProfileName()
        getImage(imageName: "UserImage.png")
        
    }
    
    func getProfileName () {
        _usernameBtn.text = user.getusername()
        _usernameBtn.textColor = UIColor.black
        _usernameBtn.textAlignment = .center
        _usernameBtn.allowsEditingTextAttributes = false
        
        print(_usernameBtn.text ?? "No Name")
    }
    
    @IBAction func changePassword(_ sender: Any) {
        AlertServices.passwordChange(vc: self) { (password) in
            if password != "" {
                //need to change for encryption
//                user.setpassword(value: password)
            }
        }
    }
    
    @IBAction func DeletionofAccount(_ sender: Any) {
        user.deleteUser()
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        deleteImage(imageName: "UserImage.png")
        
        let viewController:UIViewController = UIStoryboard(name: "signInNsignUp", bundle: nil).instantiateViewController(withIdentifier: "newAccount") as UIViewController
        // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
        
        self.present(viewController, animated: false, completion: nil)
        

        
    }
    

    
    
    
    @IBAction func takePicture(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self

        let actionSheet = UIAlertController(title: "Photo", message: "Add a Picture", preferredStyle: .actionSheet)

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
            print(" No Image")
        }
    }
    
//    func makeImageCircular (_image: UIView) {
//        _image.layer.borderWidth = 1
//        _image.layer.masksToBounds = false
//        _image.layer.borderColor = UIColor.black.cgColor
//        _image.layer.cornerRadius = _image.frame.height/2
//        _image.clipsToBounds = true
//        
//    }
    
    @IBAction func _touchIDToggle(_ sender: UISwitch) {
        
        if sender.isOn == true {
            let context:LAContext = LAContext()
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
                context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Touch ID for log In", reply: {(wasSuccessful, error) in
                    if wasSuccessful {
                        print("Successful")
                        sender.setOn(true, animated: true)
                        showBiometrics = true
                        user.setTouchIDstatus(value: true)
                    }else {
                        sender.setOn(false, animated: true)
                        print("Not Successful")
                        showBiometrics = false
                        user.setTouchIDstatus(value: false)
                    }
                })
            }
        } else {
            print("touch id off")
            
        }
    }
    

}



    






