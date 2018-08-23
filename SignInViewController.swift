//
//  SignInViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 7/20/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper


class SignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    var didSignin : Bool = false
    var user = User()
    var caddie = Caddie()
    
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.isHidden = true
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    //MARK - TextField Delegate Methods
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.delegate = self
        self.resignFirstResponder()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.delegate = self
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.delegate = self
        resignFirstResponder()
        self.postLogin()
        
        return true
    }
    
    @IBAction func didPressLogIn(_ sender: Any) {
        if emailTextField.text?.isEmpty == true || passwordTextField.text?.isEmpty == true {
            self.presentAlert(title: "Log In Error", message: "Email or Password Empty")
        }
        spinner.startAnimating()
        spinner.isHidden = false
        postLogin()
    }
    
    @IBAction func didPressSignUpButton(_ sender: Any) {
        
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "tohome" {
            let vc = segue.destination as! HomeViewController
            vc.user = self.user
        } else if segue.identifier == "usertype" {
            let vc = segue.destination as! UserTypeViewController
            vc.user = self.user
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "tohome" {
            if self.didSignin == true {
                return true
            }
        } else if identifier == "usertype" {
            return true
        }
        return false
    }
    
    //Show Alert
    func presentAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Parsing JSON Data
    func postLogin() {
        
        let parameters : [String:Any] = ["email":emailTextField.text!,
                                       "password":passwordTextField.text!]
        let signinURL = URL(string: "http://0.0.0.0:8000/login/")

        Alamofire.request(signinURL!, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate(statusCode: 200...299).validate().responseJSON { (respData) in
            
            switch respData.result{
                
            case .success(let value):
                let json = JSON(value)
                print(json)
                
                let firstName = json["first_name"].string!
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
                
                
                let didSaveToken: Bool = KeychainWrapper.standard.set(token, forKey: "token")
                print("Saved Token: \(didSaveToken)")
                
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
                
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                self.didSignin = true
                self.performSegue(withIdentifier: "tohome", sender: self)
                
            case .failure(let error):
                self.presentAlert(title: "Login Error", message: error.localizedDescription)
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                self.didSignin = false
            }
        }
    }
}


