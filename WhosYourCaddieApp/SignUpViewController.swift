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
import Lottie

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    var golfer = Golfer()
    var signUpURL = URL(string: "")
    var canSignUp : Bool = false
    var score : Float = 0.0
    
    let pickerView = UIPickerView()
    let states = [ "AK","AL","AR","AS","AZ","CA","CO","CT","DC","DE","FL","GA","GU","HI",
                   "IA","ID","IL","IN","KS","KY","LA","MA","MD","ME","MI","MN","MO","MS",
                   "MT","NC","ND","NE","NH","NJ","NM","NV","NY","OH","OK","OR","PA","PR",
                   "RI","SC","SD","TN","TX","UT","VA","VI","VT","WA","WI","WV","WY"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner.isHidden = true
        pickerView.dataSource = self
        pickerView.delegate = self
        
        stateTextField.inputView = pickerView
        
    }
    

    @IBAction func didPressSignUp(_ sender: Any) {
        canSignUp = fieldsPass()
        
        if canSignUp == true {
            if user.userType == "GOLFR" {
                self.postSignUp()
            } else {
                self.signupCaddie()
            }
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
    }
    
    //MARK: - PickerView Delegates for US States options
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stateTextField.text = states[row]
    }
    
    
    //MARK: - Formats date of birth for API Request
    
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
                                         "date_of_birth":formattedDate(),
                                        ]
        
        
        Alamofire.request(self.signUpURL!, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate(statusCode: 200...299).validate().responseJSON { (respData) in
            
            switch respData.result{
                
            case .success(let value):
                let json = JSON(value)
                print(json)
                let savedPass = self.passwordTextField.text!
                let savedEmail = self.emailTextField.text!
                
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
    

    func signupCaddie() {
        let parameters : [String:Any] = ["email":emailTextField.text!,
                                         "password":passwordTextField.text!,
                                         "first_name":firstNameTextField.text!,
                                         "last_name":lastNameTextField.text!,
                                         "address":addressTextField.text!,
                                         "city":cityTextField.text!,
                                         "state":stateTextField.text!,
                                         "zipcode":zipcodeTextField.text!,
                                         "phone_number":"5555551234",
                                         "date_of_birth":formattedDate(),
                                         "exam_grade":95.1,
                                         "profile_image":"https://vokal-io.s3.amazonaws.com/da837327b8937691012a89e212e580bc.jpg"
                                         ]
        print(parameters)
        
        
        Alamofire.request(self.signUpURL!, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate(statusCode: 200...299).validate().responseJSON { (respData) in
            print(respData)
            switch respData.result{
                
            case .success(let value):
                let json = JSON(value)
                
                let savedPass = self.passwordTextField.text!
                let savedEmail = self.emailTextField.text!
                
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
                let ranking = json["ranking"].string!
                let profilePicture = json["profile_image"].url!
                
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
                self.user.profilePicture = profilePicture
                self.caddie.ranking = ranking
                
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
        
        let _ : Bool = KeychainWrapper.standard.set(password, forKey: "password")
        let _ : Bool = KeychainWrapper.standard.set(email, forKey: "email")
        let _ : Bool = KeychainWrapper.standard.set(userId, forKey: "id")
        let _ : Bool = KeychainWrapper.standard.set(token, forKey: "token")
    
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
