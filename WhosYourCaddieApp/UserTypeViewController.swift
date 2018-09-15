//
//  UserTypeViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 7/23/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit

class UserTypeViewController: UIViewController {
    var user = User()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressCaddieButton(_ sender: Any) {
    }
    
    @IBAction func didPressGolferButton(_ sender: Any) {
    }

    // MARK: - Navigation

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "caddiequizsegue" {
            let vc = segue.destination as! VideoViewController
            self.user.userType = "CADDY"
            vc.user = self.user
            
        } else if segue.identifier == "golfersegue" {
            let vc = segue.destination as! SignUpViewController
            self.user.userType = "GOLFR"
            vc.user = self.user
            vc.signUpURL = URL(string: "http://0.0.0.0:8000/api/v1/golfer/register")
        }
    }

}
