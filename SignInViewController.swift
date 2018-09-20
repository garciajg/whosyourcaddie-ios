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
import AlertTransition
import LocalAuthentication
import Lottie

class SignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    var didSignin : Bool = false
    var user = User()
    
    let animationView = LOTAnimationView(name: "loading_animation")
    
    var localTimezone:String {return TimeZone.current.identifier}
    
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.isHidden = true
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        let email = KeychainWrapper.standard.string(forKey: "email")
        let password = KeychainWrapper.standard.string(forKey: "password")
        
        if email != nil && password != nil {
            authWithTouchID(self)
        }
        
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
        self.postLogin(email: emailTextField.text!, password: passwordTextField.text!)
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resignFirstResponder()
    }
    
    @IBAction func didPressLogIn(_ sender: Any) {
        if emailTextField.text?.isEmpty == true || passwordTextField.text?.isEmpty == true {
            animationView.stop()

            self.presentAlert(title: "Log In Error", message: "Email or Password Empty")
        }
        
        spinner.startAnimating()
        spinner.isHidden = false
        postLogin(email: emailTextField.text!, password: passwordTextField.text!)
    }
    
    @IBAction func didPressSignUpButton(_ sender: Any) {
        
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {


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
    
    func authWithTouchID(_ sender: Any) {
        
        let context = LAContext()
        var error: NSError?
        
        
        // check if Touch ID is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Sign in with TouchID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(succes, error) in
                   
                    if succes {
                        let email = KeychainWrapper.standard.string(forKey: "email")
                        let password = KeychainWrapper.standard.string(forKey: "password")
                        self.postLogin(email: email!, password: password!)
                    }
                    else {
                        self.showAlertController("Touch ID Authentication Failed")
                    }
            })
        }

        else {
            showAlertController("Touch ID not available")
        }
    }
    
    
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Parsing JSON Data
    func postLogin(email:String, password:String) {
        
        let parameters : [String:Any] = ["email":email,
                                       "password":password]
        let signinURL = URL(string: "http://0.0.0.0:8000/login/")
        
        animationView.isHidden = false
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundColor = .gray
        animationView.layer.cornerRadius = animationView.frame.size.height / 8
        animationView.clipsToBounds = true
        view.addSubview(animationView)
        animationView.loopAnimation = true
        animationView.animationSpeed = 1.5
        
        animationView.play()

        Alamofire.request(signinURL!, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate(statusCode: 200...299).validate().responseJSON { (respData) in
            
            switch respData.result{
                
            case .success(let value):
                let json = JSON(value)
                
                
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
                let age = json["age"].int!
                let profileImg = json["profile_image"].url!
                
                
                let _: Bool = KeychainWrapper.standard.set(token, forKey: "token")
                let _:Bool = KeychainWrapper.standard.set(password, forKey: "password")
                let _: Bool = KeychainWrapper.standard.set(email, forKey: "email")
                
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
                self.user.age = age
                self.user.profilePicture = profileImg
                
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                self.didSignin = true
                
                self.performSegue(withIdentifier: "tohome", sender: self)
                self.animationView.stop()
                self.animationView.isHidden = true
                
            case .failure(let error):
                self.presentAlert(title: "Login Error", message: error.localizedDescription)
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                self.didSignin = false
                
                self.animationView.stop()
                self.animationView.isHidden = true
            }
        }
    }
    
    @IBAction func unwindsToSignIn(segue:UIStoryboardSegue) {
        
    }
    
    
}


