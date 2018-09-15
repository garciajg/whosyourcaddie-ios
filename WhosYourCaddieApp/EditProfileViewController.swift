//
//  EditProfileViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 8/27/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit



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

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didPressSave(_ sender: Any) {
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

}
