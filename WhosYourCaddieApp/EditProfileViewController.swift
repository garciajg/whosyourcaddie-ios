//
//  EditProfileViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 8/27/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper
import Lottie



class EditProfileViewController: UIViewController {

    @IBOutlet weak var editProfileImage: UIImageView!
    @IBOutlet weak var editFirstNameField: UITextField!
    @IBOutlet weak var editLastNameField: UITextField!
    @IBOutlet weak var editEmailField: UITextField!
    @IBOutlet weak var editPhoneNumberField: UITextField!
    @IBOutlet weak var editAddressField: UITextField!
    @IBOutlet weak var editStateField: UITextField!
    @IBOutlet weak var editZipcodeField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var editCityField: UITextField!
    
    var caddie = Caddie()
    var golfer = Golfer()
    var user = User()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if user.userType == "CADDY" {
            populateCaddieFields()
        } else {
            populateGolferFields()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didPressSave(_ sender: Any) {
        
        if user.userType == "CADDY" {
            patchCaddieData()
        } else {
            patchGolferData()
        }
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //MARK: - Setup Caddie Fields
    func populateCaddieFields() {
        editFirstNameField.text = caddie.firstName
        editLastNameField.text = caddie.lastName
        editEmailField.text = caddie.email
        editPhoneNumberField.text = caddie.phoneNumber
        editAddressField.text = caddie.address
        editStateField.text = caddie.state
        editZipcodeField.text = caddie.zipcode
        editCityField.text = caddie.city
    }
    
    
    //MARK: - Setup Golfer Fields
    func populateGolferFields() {
        editFirstNameField.text = golfer.firstName
        editLastNameField.text = golfer.lastName
        editEmailField.text = golfer.email
        editPhoneNumberField.text = golfer.phoneNumber
        editAddressField.text = golfer.address
        editStateField.text = golfer.state
        editZipcodeField.text = golfer.zipcode
        editCityField.text = golfer.city
    }
    
    
    //MARK: - Patch Caddie Data
    
    func patchCaddieData() {
        
        let PATCH_URL = "http://0.0.0.0:8000/api/v1/caddie/\(caddie.caddieID)"
        
        let parameters : [String:Any] = [
            "first_name"   : editFirstNameField?.text ?? "",
            "last_name"    : editLastNameField?.text ?? "",
            "email"        : editEmailField?.text ?? "",
            "phone_number" : editPhoneNumberField?.text ?? "",
            "address"      : editAddressField?.text ?? "",
            "state"        : editStateField?.text ?? "",
            "zipcode"      : editZipcodeField?.text ?? "",
            "city"         : editCityField?.text ?? ""
        ]
        
        let headers = authHeaders()
        
        Alamofire.request(PATCH_URL, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200...299).responseData { (patchData) in
            switch patchData.result {
            case .success(let value):
                let json = JSON(value)

                self.caddie.firstName = json["first_name"].string!
                self.caddie.lastName = json["last_name"].string!
                self.caddie.email = json["email"].string!
                self.caddie.phoneNumber = json["phone_number"].string!
                self.caddie.address = json["address"].string!
                self.caddie.state = json["state"].string!
                self.caddie.zipcode = json["zipcode"].string!
                self.caddie.city = json["city"].string!
                
                
                self.performSegue(withIdentifier: "unwindtoprofilesegue", sender: self)
                
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    //MARK: - Patch Gofler Data
    func patchGolferData() {
        
        let PATCH_URL = "http://0.0.0.0:8000/api/v1/caddie/\(golfer.golferID)"
        
        let parameters : [String:Any] = [
            "first_name"   : editFirstNameField?.text ?? "",
            "last_name"    : editLastNameField?.text ?? "",
            "email"        : editEmailField?.text ?? "",
            "phone_number" : editPhoneNumberField?.text ?? "",
            "address"      : editAddressField?.text ?? "",
            "state"        : editStateField?.text ?? "",
            "zipcode"      : editZipcodeField?.text ?? "",
            "city"         : editCityField?.text ?? ""
        ]
        
        let headers = authHeaders()
        
        Alamofire.request(PATCH_URL, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200...299).responseData { (patchData) in
            switch patchData.result {
            case .success(let value):
                let json = JSON(value)
                
                self.golfer.firstName = json["first_name"].string!
                self.golfer.lastName = json["last_name"].string!
                self.golfer.email = json["email"].string!
                self.golfer.phoneNumber = json["phone_number"].string!
                self.golfer.address = json["address"].string!
                self.golfer.state = json["state"].string!
                self.golfer.zipcode = json["zipcode"].string!
                self.caddie.city = json["city"].string!
                
                self.performSegue(withIdentifier: "unwindtoprofilesegue", sender: self)
                
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    //MARK: - Authentication Headers
    public func authHeaders() -> HTTPHeaders {
        let token = KeychainWrapper.standard.string(forKey: "token")
        let headers : HTTPHeaders = [
            "Authorization":"Bearer \(token!)",
            "Accept": "application/json"
        ]
        
        return headers
    }

}
