//
//  CaddieDetailViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 8/30/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper
import SwiftyJSON

class CaddieDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var caddieProfileImage: UIImageView!
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var greenSkillsLabel: UILabel!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var reviewTableView: UITableView! {
        didSet{
            reviewTableView.rowHeight = UITableViewAutomaticDimension
            reviewTableView.estimatedRowHeight = 200
        }
    }
    
    
    
    
    var caddie = Caddie()
    var loop = Loop()
    var golfer = Golfer()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(loop.course?.name)
        print(caddie.firstName)
        self.reviewTableView.delegate = self
        self.reviewTableView.dataSource = self
        self.reviewTableView.reloadData()
        // Do any additional setup after loading the view.
        retrieveCaddieDetails(id: caddie.id)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.caddie.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "caddiedetailreview") as! ProfileReviewTableViewCell
        let rev = self.caddie.reviews[indexPath.row]
        cell.reviewCommentLabel.text = rev.comment
        cell.reviewCreatedLabel.text = rev.createdOn
        cell.reviewGreenSkillsLabel.text = String(format: "%.2f", rev.greenSkills)
        cell.reviewRatingLabel.text = String(format: "%.2f", rev.rating)
        cell.reviewNameLabel.text = rev.createdBy
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
    
    func retrieveCaddieDetails(id:Int) {
        let caddieURL = "http://0.0.0.0:8000/api/v1/caddie/\(id)"
        let headers = authHeaders()
        
        Alamofire.request(caddieURL, headers:headers).responseJSON { (respData) in
            switch respData.result {
                
            case .success(let value):
                let json = JSON(value)
                
//                let rating = json["rating"].double!
//                let greenSkils = json["green_skills"].double!
//                let firstName = json["first_name"].string!
//                let lastName = json["last_name"].string!
//                let email = json["email"].string!
//                let state = json["state"].string!
//                let city = json["city"].string!
//                let zipcode = json["zipcode"].string!
//                let address = json["address"].string!
//                let phoneNumber = json["phone_number"].string!
//                let dateOfBirth = json["date_of_birth"].string!
//                let userType = json["user_type"].string!
//                let id = json["caddie_id"].int!
//                
//                for (_, id) in json["loops"]{
//                    let loop = Loop()
//                    loop.id = id.int!
//                    
//                    self.caddie.loops.append(loop)
//                    
//                }
//                
//                self.caddie.id = id
//                self.caddie.address = address
//                self.caddie.city = city
//                self.caddie.dateOfBirth = dateOfBirth
//                self.caddie.email = email
//                self.caddie.firstName = firstName
//                self.caddie.lastName = lastName
//                self.caddie.phoneNumber = phoneNumber
//                self.caddie.state = state
//                self.caddie.zipcode = zipcode
//                self.caddie.userType = userType
//                self.caddie.rating = rating
//                self.caddie.greenSkills = greenSkils
                
//                self.profileRatingLabel.text = String(format: ".2f", rating)
//                self.profileGreenSkillsLabel.text = String(format: ".2f", greenSkils)
//
//                let age = self.getUserAge(birthDate: self.caddie.dateOfBirth)
//                self.caddie.age = age
                
//                self.profileAgeLabel.text = "Age: \(age)"
//                self.profileLocationLabel.text = "From: \(city), \(state)"
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func authHeaders() -> HTTPHeaders {
        let token = KeychainWrapper.standard.string(forKey: "token") as! String
        let headers : HTTPHeaders = [
            "Authorization":"Bearer \(token)",
            "Accept": "application/json"
        ]
        
        return headers
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
