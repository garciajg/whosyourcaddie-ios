//
//  SignUpViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 6/26/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class SignUpViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPassTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!
    @IBOutlet weak var birthdayDatePicker: UIDatePicker!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var didSignUp : Bool = false
    var user = User()
    var caddie = Caddie()
    var signUpURL = URL(string: "")
    var canSignUp : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.spinner.isHidden = true
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController.
//    }
//    
    @IBAction func didPressSignUp(_ sender: Any) {
        canSignUp = fieldsPass()
        if canSignUp == true {
            postSignUp()
            spinner.startAnimating()
            spinner.isHidden = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    
    @IBAction func didDatePickerChange(_ sender: Any) {
        self.formattedDate()
        print(self.formattedDate())
    }
    
    
    
    
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: birthdayDatePicker.date)
        
        return formattedDate
    }
    
    func postSignUp() {

        let parameters : [String:Any] = ["email":emailTextField.text!,
                                         "password":passwordTextField.text!,
                                         "first_name":firstNameTextField.text!,
                                         "last_name":lastNameTextField.text!,
                                         "address":addressTextField.text!,
                                         "city":cityTextField.text!,
                                         "state":stateTextField.text!,
                                         "zipcode":zipcodeTextField.text!,
                                         "phone_number":"5555551234",
                                         "date_of_birth":formattedDate()]
        
        
        Alamofire.request(self.signUpURL!, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate(statusCode: 200...299).validate().responseJSON { (respData) in
            
            switch respData.result{
                
            case .success(let value):
                let json = JSON(value)
                print(json)
                
                let savedPass = self.passwordTextField.text!
                let savedEmail = self.emailTextField.text!
                
                var firstName = json["first_name"].string!
                let lastName = json["last_name"].string!
                let email = json["email"].string!
                let state = json["state"].string!
                let city = json["city"].string!
                let zipcode = json["zipcode"].string!
                let address = json["address"].string!
                let phoneNumber = json["phone_number"].string!
                let dateOfBirth = json["date_of_birth"].string!
                let userType = json["user_type"].string!
                let token = json["token"].string!
                let id = json["id"].int!
                
                self.user.id = id
                self.user.address = address
                self.user.city = city
                self.user.dateOfBirth = dateOfBirth
                self.user.email = email
                self.user.firstName = firstName
                self.user.lastName = lastName
                self.user.phoneNumber = phoneNumber
                self.user.state = state
                self.user.zipcode = zipcode
                self.user.userType = userType
                
                
                self.saveUsersData(password: savedPass, email: savedEmail, userId: self.user.id, token:token)
                
                self.didSignUp = true
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                
                self.performSegue(withIdentifier: "homesegue", sender: self)
            case .failure(let error):
                self.errorAlert(title: "Error", message: error.localizedDescription, actionTitle: "Dismiss")
                self.didSignUp = false
            }
        }
    }
    
    
    func fieldsPass() -> Bool {
        let emptyMessage = "Make sure no fields are empty."
        let passNotMatchMessage = "Make sure you passwords match."
        if firstNameTextField.text?.isEmpty == true ||
            passwordTextField.text?.isEmpty == true ||
            lastNameTextField.text?.isEmpty == true ||
            emailTextField.text?.isEmpty == true ||
            addressTextField.text?.isEmpty == true ||
            cityTextField.text?.isEmpty == true ||
            stateTextField.text?.isEmpty == true ||
            zipcodeTextField.text?.isEmpty == true {
            
            errorAlert(title: "Empty Fields", message: emptyMessage, actionTitle: "Dismiss")
            return false
        }
        
        if passwordTextField.text != verifyPassTextField.text {
            
            errorAlert(title: "Passwords Don't Match", message: passNotMatchMessage, actionTitle: "Dismiss")
            return false
        }
        
        if (zipcodeTextField.text?.count)! < 5 ||
            (zipcodeTextField.text?.count)! > 5 {

            errorAlert(title: "Bad Zipcode", message: "Make sure zipcode has 5 number", actionTitle: "Dismiss")
            return false

        }
        return true
    }
    
    func errorAlert(title:String, message:String, actionTitle:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveUsersData(password:String, email:String, userId:Int, token:String) {
        
        let didSavePassword : Bool = KeychainWrapper.standard.set(password, forKey: "password")
        let didSaveEmail : Bool = KeychainWrapper.standard.set(email, forKey: "email")
        let didSaveUserId : Bool = KeychainWrapper.standard.set(userId, forKey: "id")
        let didSaveToken : Bool = KeychainWrapper.standard.set(token, forKey: "token")
        
        print("Saved Password: \(didSavePassword)")
        print("Saved Email: \(didSaveEmail)")
        print("Saved id: \(didSaveUserId)")
        print("Saved token: \(didSaveToken)")
    
    }
  
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "homesegue" {
            if self.didSignUp == true {
                let vc = segue.destination as! HomeViewController
                vc.user = self.user
            }
        }
    }
    
}
