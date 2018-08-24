//
//  HomeViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 7/20/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class HomeViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var user = User()
    var caddie = Caddie()
    var loop = Loop()
    var review = Review()

    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeLabel.text = "Welcome \(user.firstName)!"
        self.navigationItem.setHidesBackButton(true, animated: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapViewProfile(_ sender: Any) {
        self.performSegue(withIdentifier: "profilesegue", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "profilesegue" {
            let vc = segue.destination as! ProfileViewController
            vc.user = self.user
            vc.caddie = self.caddie
            vc.loop = self.loop
            vc.review = self.review
        }

    }
}
