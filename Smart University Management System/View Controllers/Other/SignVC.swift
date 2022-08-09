//
//  SignVC.swift
//  Attendance System
//
//  Created by Kamal Trapasiya on 2021-08-04.
//

import UIKit
import SkyFloatingLabelTextField
import Alamofire

/* Identify
 
 if id == 1 : Admin
 if id == 2 : Professor
 if id == 3 : Student
 
*/

class SignVC: UIViewController {
    
    @IBOutlet weak var studentIDTxtField: SkyFloatingLabelTextField!
    @IBOutlet weak var passTxtField: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        designInit()
    }
    
    func designInit() {
        self.view.gradient(colors: [UIColor.init(named: "Color")!, UIColor.init(named: "Color")!.withAlphaComponent(0.7)])
        
        studentIDTxtField.applyCommonDesign()
        studentIDTxtField.tintColor = .white
        passTxtField.applyCommonDesign()
        passTxtField.tintColor = .white
        passTxtField.isSecureTextEntry = true
        
        studentIDTxtField.placeholder = "ID / Email"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        studentIDTxtField.text?.removeAll()
        passTxtField.text?.removeAll()
    }
    
    @IBAction func signINAction(_ sender: Any) {
        if !studentIDTxtField.isValidate() {
            studentIDTxtField.errorMessage = "ID / Email"
        }
        else if !passTxtField.isValidate() {
            passTxtField.errorMessage = "Password"
        }
        else {
            //Sign In
            authentication()
            //self.performSegue(withIdentifier: "adminSegue", sender: nil)
        }
    }
    
    func authentication() {
        
        let url = "https://apidockerpython.azurewebsites.net//api/profile"
        
        let param : [String:Any] = [
            "data" : studentIDTxtField.text!
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: param)

        var request = URLRequest.init(url: URL.init(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
        
        AF.request(request).responseJSON { [self] result in
            
            if let value = result.value as? [[String:Any]] {
                if value.count > 0 {
                    let dict = value[0]
                    let valueID = Int(dict["identify"] as! String)
                    let password = dict["password"] as! String
                    if passTxtField.text == password {
                        //Success
                        
                        UserDefaults.standard.set(dict, forKey: "login")
                        UserDefaults.standard.synchronize()
                        
                        if valueID == 1 {
                            //admin
                            self.performSegue(withIdentifier: "adminSegue", sender: nil)
                        }
                        else if valueID == 2 {
                            //Faculty
                            self.performSegue(withIdentifier: "facultySegue", sender: nil)
                        }
                        else if valueID == 3 {
                            //Student
                            self.performSegue(withIdentifier: "studentSegue", sender: nil)
                        }
                    }
                    else {
                        self.view.makeToast("Wrong Password!")
                    }
                }
                else {
                    self.view.makeToast("User not found!")
                }
                
//                if value["Count"] as! Int == 0 {
//                    //Account Not Found
//                    self.view.makeToast("Account Not Found!")
//                }
//                else {
//                    if let items = value["Items"] as? [[String:Any]] {
//                        let item = items[0]
//                        if let pass = item["password"] as? [String:Any] {
//                            if let passValue = pass["S"] as? String {
//                                if passValue == self.passTxtField.text! {
//                                    //Login Successfully
//                                    self.view.makeToast("Login Successfully!")
//
//                                    UserDefaults.standard.setValue(item, forKey: "login")
//                                    UserDefaults.standard.synchronize()
//
//                                    if id == 0 {
//                                        //Admin
//                                        self.performSegue(withIdentifier: "adminSegue", sender: nil)
//                                    }
//                                    else if id == 1 {
//                                        //Faculty
//                                        self.performSegue(withIdentifier: "facultySegue", sender: nil)
//                                    }
//                                    else {
//                                        //Student
//                                        self.performSegue(withIdentifier: "studentSegue", sender: nil)
//                                    }
//                                }
//                                else {
//                                    self.view.makeToast("Wrong Password!")
//                                }
//                            }
//                        }
//                    }
//
//                }
            }
            else {
                self.view.makeToast("Something Went Wrong!")
            }
        }
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        self.performSegue(withIdentifier: "singUpSegue", sender: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
