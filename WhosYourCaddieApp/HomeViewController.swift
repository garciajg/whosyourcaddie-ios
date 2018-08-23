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
        getUserProfileData()

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
    
    
    
    func getUserProfileData() {
        
        if user.userType == "CADDY" {
        
            let caddieURL = "http://0.0.0.0:8000/caddie/"
            let token = KeychainWrapper.standard.string(forKey: "token") as! String
            let headers : HTTPHeaders = [
                "Authorization":"Bearer \(token)",
                "Accept": "application/json"
            ]
            print(headers)
            
            Alamofire.request(caddieURL, headers:headers).responseJSON { (respData) in
                switch respData.result {
                    
                case .success(let value):
                    let json = JSON(value)[0]
                    print(json)
                    
                    let rating = json["rating"].double!
                    let greenSkils = json["green_skills"].double!
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
                    let id = json["caddie_id"].int!
//                    let loops = json["loops"]
                    
                    for (_, loop) in json["loops"]{
            
                        self.loop.id = loop["id"].int!
                        self.loop.caddie = self.caddie
                        self.loop.accepted = loop["accepted"].bool!
                        self.loop.cancelled = loop["cancelled"].bool!
                        self.loop.isWalking = loop["is_walking"].bool!
                        self.loop.loopDate = loop["loop_date"].string!
                        self.loop.startTime = loop["start_time"].string!

                        self.loop.numberOfHoles = loop["number_of_holes"].string!
                        
                        self.caddie.loops.append(self.loop)
                        
                    }
                    
                    for (_, review) in json["reviews"] {
                        self.review.caddie = self.caddie
                        self.review.id = review["id"].int!
                        self.review.createdOn = review["created_on"].string!
                        self.review.comment = review["comment"].string!
                        self.review.rating = review["rating"].double!.rounded()
                        self.review.greenSkills = review["green_skills"].double!.rounded()
                        
                        self.caddie.reviews.append(self.review)
                    }
                    
                    self.caddie.id = id
                    self.caddie.address = address
                    self.caddie.city = city
                    self.caddie.dateOfBirth = dateOfBirth
                    self.caddie.email = email
                    self.caddie.firstName = firstName
                    self.caddie.lastName = lastName
                    self.caddie.phoneNumber = phoneNumber
                    self.caddie.state = state
                    self.caddie.zipcode = zipcode
                    self.caddie.userType = userType
                    self.caddie.rating = rating.rounded()
                    self.caddie.greenSkills = greenSkils.rounded()
//                    self.caddie.loops = loops as! [Loop]
                    
                    
                case .failure(let error):
                    
                    print(error)
                }
            }
        } else if user.userType == "GOLFR" {
            
        }
    }

}

extension Double {
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
