//
//  ViewController.swift
//  Quick Vault
//
//  Created by administritor on 2019/5/8.
//  Copyright © 2019 KOD Inc. All rights reserved.
//

import UIKit
import RealmSwift

var user = Account()
var currentCellNum = 0
var globalcredentialList: Results<Credentials>!

class SignInViewController: UIViewController {


    @IBOutlet var _password: UITextField!
    
    
    @IBOutlet var _signinbutton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func signInProcess(_ sender: Any) {

        let password = _password.text

        if ( password == ""){
            
            AlertServices.errorPopUp(vc: self,title: "Alert", message: "Please enter a password")


            
            _password.text = ""
        
            return

        } else {
            
            if user.getpassword() == "" {
                
                AlertServices.errorPopUp(vc: self, title: "Account", message: "No account found on device")
            }

            else if (user.getpassword() == password){
                
                
                let tvc = self.storyboard?.instantiateViewController(withIdentifier: "main")
                self.show(tvc!, sender: self)

            } else {
                
                
                AlertServices.errorPopUp(vc: self, title: "Error", message: "Incorrect password entered")
                
                _password.text = ""
                

            }
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
            
            user.setpassword(value: password1!)
            
            let tvc = self.storyboard?.instantiateViewController(withIdentifier: "main")
            self.show(tvc!, sender: self)

        }
    }
    
    
}


class passwords : UITableViewController, UISearchBarDelegate {
    
    var num = 5
    var names = ["Asnj","Hasj","yuuuu", "pop", "paaaa"]
    var searchItems = [String]()
    var searching = false
    @IBOutlet var Search: UISearchBar!
    var credentialList: Results<Credentials>!
    var notificationToken: NotificationToken?
    var dispatchGroup = DispatchGroup()
    
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





